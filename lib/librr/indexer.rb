require 'eventmachine'
# require 'rsolr-async' rescue nil
require 'rsolr'


require 'librr/lib'
require 'librr/settings'


class Librr::Indexer

  def start &after_block
    @after_block = after_block

    Dir.chdir File.join(Dir.pwd, 'solr') do
      solr = 'java -jar start.jar'
      solr_in, solr_out, solr_err = redirect_std do
        EM.popen(solr, SolrManager)
      end
      EM.attach(solr_err, SolrOutHandler, self)
    end
  end


  module SolrManager

    def post_init
      $logger.info(:SolrManager){ 'start solr' }
    end

    def receive_data data
      $logger.info(:SolrManager){ "receiving solr: #{data}" }
    end

    def unbind
      $logger.info(:SolrManager){ "stop solr" }
    end

  end


  class SolrOutHandler < EventMachine::Connection

    def initialize(indexer)
      @indexer = indexer
    end

    def receive_data(data)
      if data =~ /Started SocketConnector/
        EM.next_tick do
          @indexer.after_start
        end
      end
    end

  end


  def after_start
    $logger.info(:Indexer){ 'after solr start' }
    @solr = RSolr.connect(
                  url: "http://localhost:#{Settings.solr_port}/solr",
                  read_timeout: 120, open_timeout: 120)
    @after_block.call if @after_block
  end

  def cleanup
    $logger.info(:Indexer){ 'cleanup' }
    @solr.delete_by_query '*:*'
    @solr.commit
  end

  def index_directory(dir)
    $logger.info(:Indexer){ "index dir: #{dir}" }
    Dir.glob(File.join(dir, "**/*")).each do |file|
      next unless File.file?(file)
      self.index_file(file)
    end
  end

  def remove_index_directory(dir)
    $logger.info(:Indexer){ "remove dir: #{dir}" }
    @solr.delete_by_query "filename:#{dir}*"
    @solr.commit
  end

  def index_file(file)
    return if file =~ Settings.escape_files

    if File.exists?(file)
      $logger.info(:Indexer){ "index file: #{file}" }
      @solr.delete_by_query "filename:#{file}"
      File.readlines(file).map(&:rstrip).each_with_index do |line, num|
        @solr.add id: SecureRandom.uuid, filename: file, linenum: num, line: line
      end
    else
      $logger.info(:Indexer){ "remove index file: #{file}" }
      @solr.delete_by_query "filename:#{file}"
    end
    @solr.commit
  end

  def search(str)
    $logger.info(:Indexer){ "search: #{str}" }
    result = @solr.get 'select', params: {q: "line:#{str}"}
    result['response']['docs'].map do |row|
      [row['filename'], row['linenum'], row['line']].flatten
    end
  end

end

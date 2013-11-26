require 'eventmachine'
# require 'rsolr-async' rescue nil
require 'rsolr'


require 'librr/lib'
require 'librr/settings'


class Librr::Indexer

  attr_accessor :solr_started

  def self.pid_file
    File.join(Settings::CONFIG_PATH, 'solr.pid')
  end

  def start &after_block
    @after_block = after_block

    kill_process_by_file(self.class.pid_file)

    Dir.chdir File.join(Dir.pwd, 'solr') do
      solr = 'java -jar start.jar'
      solr_in, solr_out, solr_err = redirect_std do
        EM.popen(solr, SolrManager)
        # TODO: write pid file
      end
      EM.attach(solr_err, SolrOutHandler, self)
    end
  end

  def info text
    $logger.info(:Indexer){ text }
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
      File.delete Librr::Indexer.pid_file rescue nil
    end

  end


  class SolrOutHandler < EventMachine::Connection

    def initialize(indexer)
      @indexer = indexer
    end

    def receive_data(data)
      # @indexer.info "solr output: #{data}"
      if not @indexer.solr_started and data =~ /Started SocketConnector/
        @indexer.after_start
      end
    end

  end


  def after_start
    @solr_started = true
    self.info 'after solr start'

    @solr = RSolr.connect(
                  url: "http://localhost:#{Settings.solr_port}/solr",
                  read_timeout: 10, open_timeout: 10)
    @after_block.call if @after_block
  end

  def cleanup
    self.info 'cleanup'
    @solr.delete_by_query '*:*'
    @solr.commit
  end

  def index_directory(dir)
    self.info "index dir: #{dir}"
    files = Dir.glob(File.join(dir, "**/*"))
    EM::Iterator.new(files)
      .each(
       proc { |file, iter|
              self.index_file(file) if File.file?(file)
              iter.next
            },
       proc { self.info "index dir finished: #{dir}" }
       )
  end

  def remove_index_directory(dir)
    self.info "remove dir: #{dir}"
    @solr.delete_by_query "filename:#{dir}*"
    @solr.commit
  end

  def index_file(file)
    return if file =~ Settings.escape_files

    if File.exists?(file)
      self.info "index file: #{file}"
      @solr.delete_by_query "filename:#{file}"
      data = File.readlines(file).map do |line, num|
        line = fix_encoding(line).rstrip
        {id: SecureRandom.uuid, filename: file, linenum: num, line: line}
      end
      @solr.add data
    else
      self.info "remove index file: #{file}"
      @solr.delete_by_query "filename:#{file}"
    end
    @solr.commit
  end

  def search(str, opts={})
    self.info "search: #{str}"

    rows = opts[:rows]
    rows = (2 ** 31 - 1) if opts[:all]
    result = @solr.get 'select', params: {q: "line:#{str}", rows: rows}

    result['response']['docs'].map do |row|
      [row['filename'], row['linenum'], row['line']].flatten
    end
  end

end

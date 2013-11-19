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
      puts 'start solr'
    end

    def receive_data data
      puts "receiving solr: #{data}"
    end

    def unbind
      puts "stop solr"
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
    puts 'after solr start'
    @solr = RSolr.connect(
                  url: "http://localhost:#{Settings::SOLR_PORT}/solr",
                  read_timeout: 120, open_timeout: 120)
    @after_block.call if @after_block
  end

  def cleanup
    @solr.delete_by_query '*:*'
    @solr.commit
  end

  def index_directory(dir)
    Dir.glob(File.join(dir, "**/*")).each do |file|
      next unless File.file?(file)
      self.index_file(file)
    end
  end

  def index_file(file)
    return if file =~ Settings::ESCAPE_FILES
    puts "index file: #{file}"
    File.readlines(file).each_with_index do |line, num|
      @solr.add id: SecureRandom.uuid, filename: file, linenum: num, line: line
    end
    @solr.commit
  end

  def search(str)
    result = @solr.get 'select', params: {q: "line:#{str}"}
    result['response']['docs'].map do |row|
      [row['filename'], row['linenum'], row['line']].flatten
    end
  end

end

require 'eventmachine'
# require 'rsolr-async' rescue nil
require 'rsolr'


require 'librr/lib'
require 'librr/settings'
require 'librr/delay_iterator'


class Librr::Indexer
  include Librr::Logger::ClassLogger

  attr_accessor :solr_started

  SLICE_NUM = 300

  def self.pid_file
    Settings.in_dir('solr.pid')
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

  module SolrManager
    include Librr::Logger::ClassLogger

    def post_init
      self.info "start solr"
    end

    def receive_data data
      self.info "receiving solr: #{data}"
    end

    def unbind
      self.info "stop solr"
      File.delete Librr::Indexer.pid_file rescue nil
    end

  end


  class SolrOutHandler < EventMachine::Connection

    def initialize(indexer)
      @indexer = indexer
    end

    def receive_data(data)
      # File.open(Settings.in_dir('solr.log'), 'a+'){|f| f.write(data)}
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

  def run_solr &block
    retry_times = 2
    begin
      block.call
    rescue Net::ReadTimeout
      retry_times -= 1
      retry if retry_times >= 0
    end
  end

  def cleanup
    self.info 'cleanup'
    self.run_solr {
      @solr.delete_by_query '*:*'
      @solr.commit
    }
  end

  def index_directory(dir)
    self.info "index dir: #{dir}"
    files = Dir.glob(File.join(dir, "**/*"))
    EM::Iterator.new(files)
      .each(
       proc { |file, iter|
              if File.file?(file)
                self.index_file(file){ iter.next }
              else
                iter.next
              end
            },
       proc { self.info "index dir finished: #{dir}" }
       )
  end

  def remove_index_directory(dir)
    self.info "remove dir: #{dir}"
    self.run_solr {
      @solr.delete_by_query "filename:#{dir}*"
      @solr.commit
    }
  end

  def index_file(file, &block)
    return if File.basename(file) =~ Settings.escape_files

    self.run_solr {
      @solr.delete_by_query "filename:#{file}"
      @solr.commit
    }

    unless File.exists?(file)
      self.info "remove index file: #{file}"
      block.call if block
      return
    end

    self.info "index file: #{file}"
    f = File.open(file)
    enum = f.each.each_slice(SLICE_NUM).each_with_index
    self.info "file indexing...."
    DelayIterator.new(enum)
      .each(
       proc { |lines, i|
              data = lines.each_with_index.map do |line, j|
                num = SLICE_NUM * i + j
                line = fix_encoding(line).rstrip
                {id: SecureRandom.uuid, filename: file, linenum: num, line: line}
              end

              self.run_solr {
                @solr.add data
                @solr.commit
              }

              self.info "working on lines: #{i*SLICE_NUM}"
            },
       proc {
              f.close
              block.call if block
            }
       )
  end

  def search(str, opts={})
    self.info "search: #{str}"

    rows = opts[:rows] || 30
    rows = (2 ** 31 - 1) if opts[:all]

    result = self.run_solr {
      @solr.get 'select', params: {q: "line:#{str}", rows: rows}
    }

    result['response']['docs'].map do |row|
      [row['filename'], row['linenum'], row['line']].flatten
    end
  end

end

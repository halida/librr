require 'eventmachine'
require 'evma_httpserver'

require 'librr/settings'
require 'json'
require 'rack'

EventMachine.kqueue = true if EventMachine.kqueue?

class Indexer
  FILES = {}

  def index_directory(dir)
    Dir.glob(File.join(dir, "**/*")).each do |file|
      next unless File.file?(file)
      self.index_file(file)
    end
  end

  def index_file(file)
    lines = File.readlines(file)
    FILES[file] = lines
  end

  def search(str)
    FILES.each do |file, lines|
      lines.each_with_index do |line, index|
        next unless line.index(str)
        return [file, index, line]
      end
    end
  end
end

$indexer = Indexer.new

class DirMonitor
  DIRS = ['/Users/halida/data/workspace/librr']
  OBJS = {}

  def start
    DIRS.each do |dir|
      self.add_directory(dir)
    end
  end

  def add_directory(dir)
    puts "add directory: #{dir}"
    $indexer.index_directory(dir)
    o = EventMachine.watch_file(dir, DirWatcher)
    OBJS[dir] = o
  end

  def remove_directory(dir)
    puts "remove directory: #{dir}"
    OBJS[dir].stop_watching
  end
end


module DirWatcher
  def file_modified
    puts "#{path} modified"
  end

  def file_moved
    puts "#{path} moved"
  end

  def file_deleted
    puts "#{path} deleted"
  end

  def unbind
    puts "#{path} monitoring ceased"
  end
end


$monitor = DirMonitor.new

class Librr::CmdServer < EM::Connection
  include EM::HttpServer

  def post_init
    super
    no_environment_strings
  end

  def process_http_request
    puts  @http_request_uri
    response = EM::DelegatedHttpResponse.new(self)
    response.status = 200
    response.content_type 'application/json'
    params = Rack::Utils.parse_nested_query(@http_post_content)
    response.content = JSON.dump(self.handle_cmd(params))
    response.send_response
  end

  def handle_cmd(params)
    case params['cmd']
    when 'start'
    when 'stop'
    when 'add'
      EM.next_tick{
        $monitor.add_directory(params['dir'])
      }
    when 'remove'
      EM.next_tick{
        $monitor.remove_directory(params['dir'])
      }
    when 'list'
      self.dirs
    when 'search'
      $indexer.search(params['text'])
    end
  end
end

class Librr::Runner
  def run
    EventMachine.run {
      EventMachine.start_server "127.0.0.1", Settings::RUNNER_PORT, Librr::CmdServer
    }
  end
end

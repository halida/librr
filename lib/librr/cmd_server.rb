require 'eventmachine'
require 'evma_httpserver'

require 'json'
require 'rack'


class Librr::CmdServer
  attr_accessor :monitor, :indexer

  def init opts
    self.monitor = opts[:monitor]
    self.indexer = opts[:indexer]
    CmdServerHandler.set_server(self)
  end

  def start(&block)
    EventMachine.start_server "localhost", Settings.runner_port, CmdServerHandler
    EM.add_timer(1){ block.call if block }
  end


  class CmdServerHandler < EM::Connection
    include EM::HttpServer
    include Librr::Logger::ClassLogger

    def self.set_server(server)
      @@server = server
    end

    def process_http_request
      # puts @http_request_uri
      response = EM::DelegatedHttpResponse.new(self)
      response.status = 200
      response.content_type 'application/json'
      params = Rack::Utils.parse_nested_query(@http_post_content)
      response.content = JSON.dump(self.handle_cmd(params))
      response.send_response
    end

    def handle_cmd(params)
      self.info "on receive: #{params.to_s}"
      case params['cmd']
      when 'ping'
        'pong'

      when 'stop'
        puts "server stopping.."
        EM.next_tick{
          EM.stop
        }

      when 'add'
        EM.next_tick{
          @@server.monitor.add_directory(params['dir'])
        }

      when 'remove'
        EM.next_tick{
          @@server.monitor.remove_directory(params['dir'])
        }

      when 'list'
        @@server.monitor.dirs.to_a

      when 'reindex'
        EM.next_tick{
          @@server.monitor.reindex
        }

      when 'search'
        @@server.indexer.search(
                         params['text'],
                         rows: params['rows'],
                         all: params['all'],
                         location: params['location'],
                         )

      else
        raise Exception, "cmd unknown: #{params['cmd']}"

      end
    end

  end

end

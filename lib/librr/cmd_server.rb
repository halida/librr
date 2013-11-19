require 'eventmachine'
require 'evma_httpserver'

require 'json'
require 'rack'

class Librr::CmdServer < EM::Connection
  include EM::HttpServer

  def self.init opts
    @@monitor = opts[:monitor]
    @@indexer = opts[:indexer]
  end

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
        @@monitor.add_directory(params['dir'])
      }
    when 'remove'
      EM.next_tick{
        @@monitor.remove_directory(params['dir'])
      }
    when 'list'
      self.dirs
    when 'reindex'
      @@monitor.reindex
    when 'search'
      @@indexer.search(params['text'])
    end
  end
end

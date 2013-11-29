require 'net/http'
require 'json'

require 'librr/logger'
require 'librr/server_starter'


class Librr::CmdClient
  include Librr::Logger::ClassLogger

  def initialize host, port
    @host = host
    @port = port
  end

  def check_start(sync=false)
    begin
      self.run_cmd(:ping)
      return true
    rescue Errno::ECONNREFUSED => e
    end

    ServerStarter.start_server(sync)
    return false
  end

  def cmd cmd, params={}
    begin
      return self.run_cmd cmd, params
    rescue Errno::ECONNREFUSED => e
    end

    puts "daemon not start, starting.."
    ServerStarter.start_server(false)
    ServerStarter.wait_for_server_started do
      self.run_cmd cmd, **params
    end
  end

  def run_cmd cmd, params={}
    params[:cmd] = cmd
    url = '/cmd'
    self.debug("sending: #{params}")
    result = Net::HTTP.post_form(URI.parse("http://#{@host}:#{@port}#{url}"), params)
    JSON.load(result.body)
  end
end

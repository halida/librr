require 'net/http'
require 'json'

require 'librr/logger'
require 'librr/server_controller'


class Librr::CmdClient
  include Librr::Logger::ClassLogger

  def initialize host, port
    @host = host
    @port = port
  end

  def server_started?
    begin
      self.run_cmd(:ping)
      return true
    rescue Errno::ECONNREFUSED => e
    end

    return false
  end

  def check_start(sync=false)
    if self.server_started?
      puts 'daemon already started..'
    else
      ServerController.start_server(sync)
    end
  end

  def check_stop
    if self.server_started?
      self.cmd(:stop) rescue nil
      ServerController.wait_for_server_stopped do
        puts "daemon stopped."
      end
    else
      puts 'daemon already stopped..'
    end
  end

  def cmd cmd, params={}
    begin
      return self.run_cmd cmd, params
    rescue Errno::ECONNREFUSED => e
    end

    puts "daemon not start, starting.."
    ServerController.start_server(false)
    ServerController.wait_for_server_started do
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

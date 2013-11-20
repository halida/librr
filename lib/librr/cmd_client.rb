require 'net/http'
require 'json'

require 'librr/server_starter'


class Librr::CmdClient

  def initialize host, port
    @host = host
    @port = port
    @server = nil
  end

  def check_start(sync)
    begin
      self.run_cmd(:ping)
      return true
    rescue Errno::ECONNREFUSED => e
      ServerStarter.start_server(sync)
      return
    end
  end

  def cmd cmd, **params
    retried = 0

    begin
      self.run_cmd cmd, **params
    rescue Errno::ECONNREFUSED => e

      puts "server not start, starting.."
      ServerStarter.start_server(false)
      sleep(3) # todo for wait server started

      retried += 1
      if retried > 3
        puts "server not starting, something is wrong."
        exit
      end

      retry
    end
  end

  def run_cmd cmd, **params
    params[:cmd] = cmd
    url = '/cmd'
    result = Net::HTTP.post_form(URI.parse("http://#{@host}:#{@port}#{url}"), params)
    JSON.load(result.body)
  end
end

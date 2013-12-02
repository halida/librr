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

  def cmd cmd, params={}
    begin
      return self.run_cmd cmd, params
    rescue Errno::ECONNREFUSED => e
    end

    puts "daemon not start, starting.."
    on = proc { puts 'waiting for daemon started..' }
    after = proc { puts 'daemon started.'; self.run_cmd cmd, **params }
    wrong = proc { puts "daemon not starting, something is wrong." }

    ServerController.start_server(false)
    ServerController.wait_for_server_started(on, after, wrong)
  end

  def server_started?
    begin
      self.run_cmd(:ping)
      return true
    rescue Errno::ECONNREFUSED => e
    end

    return false
  end

  def start(sync=false)
    if self.server_started?
      puts 'daemon already started..'
      return
    end

    puts 'daemon starting..'
    on = proc { puts 'waiting for daemon started..' }
    after = proc { puts 'daemon started.' }
    wrong = proc { puts "daemon not starting, something is wrong." }

    ServerController.start_server(sync)
    ServerController.wait_for_server_started(on, after, wrong)
  end

  def stop
    unless self.server_started?
      puts 'daemon already stopped..'
      return
    end

    self.cmd(:stop) rescue nil
    on = proc { puts 'waiting for daemon stopped..' }
    after = proc { puts "daemon stopped." }
    wrong = proc { puts "daemon is still running, something is wrong." }
    ServerController.wait_for_server_stopped(on, after, wrong)
  end

  protected

  def run_cmd cmd, params={}
    params[:cmd] = cmd
    url = '/cmd'
    self.debug("sending: #{params}")
    result = Net::HTTP.post_form(URI.parse("http://#{@host}:#{@port}#{url}"), params)
    JSON.load(result.body)
  end

end

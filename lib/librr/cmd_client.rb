require 'net/http'
require 'json'

require 'librr/logger'
require 'librr/server_controller'
require 'librr/displayer'


class Librr::CmdClient
  include Librr::Logger::ClassLogger
  include Librr::Displayer

  def initialize host, port
    @host = host
    @port = port
  end

  def cmd cmd, params={}
    begin
      return self.run_cmd cmd, params
    rescue Errno::ECONNREFUSED => e
    end

    self.show "daemon not start, starting.."
    on = proc { self.show 'waiting for daemon started..' }
    after = proc { self.show 'daemon started.'; self.run_cmd cmd, **params }
    wrong = proc { self.show "daemon not starting, something is wrong." }

    ServerController.start_server(false)
    ServerController.wait_for_started(on, after, wrong)
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
      self.show 'daemon already started..'
      return
    end

    self.show 'daemon starting..'
    on = proc { self.show 'waiting for daemon started..' }
    after = proc { self.show 'daemon started.' }
    wrong = proc { self.show "daemon not starting, something is wrong." }

    ServerController.start_server(sync)
    ServerController.wait_for_started(on, after, wrong) unless sync
  end

  def stop
    unless self.server_started?
      self.show 'daemon already stopped..'
      return
    end

    self.cmd(:stop) rescue nil
    on = proc { self.show 'waiting for daemon stopped..' }
    after = proc { self.show "daemon stopped." }
    wrong = proc { self.show "daemon is still running, something is wrong." }
    ServerController.wait_for_stopped(on, after, wrong)
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

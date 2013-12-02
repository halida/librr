# copy from gem daemons file: daemonize.rb
# todo: may has secruity risk
require 'librr/lib'
require 'librr/logger'
require 'librr/settings'

module ServerController
  include Librr::Logger::ClassLogger

  extend self

  def run
    require 'librr'
    require 'librr/runner'

    Librr::Runner.new.run!
  end

  def start_server(sync)
    if sync
      Librr::Logger.instance.logger.level = Logger::DEBUG
      return self.run
    end

    Process.fork do
      sess_id = Process.setsid
      Process.fork do
        redirect_std do
          # for daemon, logger all information to log file
          logger = Logger.new(Settings.in_dir('daemon.log'), 10, 1024000)
          logger.level = Logger::DEBUG
          Librr::Logger.instance.logger = logger
          self.debug "daemon started."
          self.run
        end
        exit
      end
      exit
    end
  end

  def wait_for_server_started on, after, wrong
    10.times.each do
      sleep(1)
      on.call

      return after.call if File.exists?(Settings::PID_FILE)
    end

    wrong.call
    exit
  end

  def wait_for_server_stopped on, after, wrong
    10.times.each do
      sleep(1)
      on.call

      return after.call unless File.exists?(Settings::PID_FILE)
    end

    wrong.call
    exit
  end
end

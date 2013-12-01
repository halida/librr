require 'eventmachine'

require 'librr/settings'
require 'librr/indexer'
require 'librr/dir_monitor'
require 'librr/cmd_server'


EventMachine.kqueue = true if EventMachine.kqueue?


class Librr::Runner
  include Librr::Logger::ClassLogger

  def run!
    self.clear_pid
    @stoping = false

    EventMachine.run do
      trap("SIGINT") do
        return if @stoping
        @stoping = true

        EM.stop
        puts "eventmachine stopping.."
        # todo commandline still show ^C?
        self.clear_pid
      end

      indexer = Librr::Indexer.new
      monitor = Librr::DirMonitor.get_monitor
      server  = Librr::CmdServer.new

      monitor.init(indexer: indexer)
      server.init(indexer: indexer, monitor: monitor)

      indexer.start do
        monitor.start do
          server.start do
            self.info "daemon started"
            self.write_pid
          end
        end
      end

    end

    self.info "eventmachine stopped."
  end

  def write_pid
    filename = Settings::PID_FILE
    File.open(filename, 'w+'){ |f| f.write(Process.pid.to_s) }
  end

  def clear_pid
    filename = Settings::PID_FILE
    File.delete(filename) rescue nil
  end
end

require 'eventmachine'

require 'librr/settings'
require 'librr/indexer'
require 'librr/dir_monitor'
require 'librr/cmd_server'


EventMachine.kqueue = true if EventMachine.kqueue?


class Librr::Runner
  def run!
    self.clear_pid

    EventMachine.run do
      trap("SIGINT") do
        EM.stop
        puts "eventmachine graceful stops."
        # todo commandline still show ^C?
        self.clear_pid
      end

      indexer = Librr::Indexer.new
      monitor = Librr::DirMonitor.new
      server  = Librr::CmdServer.new

      monitor.init(indexer: indexer)
      server.init(indexer: indexer, monitor: monitor)

      indexer.start do
        monitor.start do
          server.start do
            puts "server started"
            self.write_pid
          end
        end
      end

    end
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

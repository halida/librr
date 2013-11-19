require 'eventmachine'

require 'librr/settings'
require 'librr/indexer'
require 'librr/dir_monitor'
require 'librr/cmd_server'


EventMachine.kqueue = true if EventMachine.kqueue?


class Librr::Runner
  def run!
    EventMachine.run do
      trap("SIGINT") do
        EM.stop
        puts "eventmachine graceful stops."
        # todo commandline still show ^C?
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
          end
        end
      end

    end
  end
end

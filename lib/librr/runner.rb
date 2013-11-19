require 'eventmachine'

require 'librr/settings'
require 'librr/indexer'
require 'librr/dir_monitor'
require 'librr/cmd_server'

EventMachine.kqueue = true if EventMachine.kqueue?

class Librr::Runner
  def run
    EventMachine.run {
      indexer = Indexer.new
      monitor = DirMonitor

      DirMonitor.init(indexer: indexer)
      Librr::CmdServer.init(indexer: indexer, monitor: monitor)

      EventMachine.start_server "127.0.0.1", Settings::RUNNER_PORT, Librr::CmdServer
      indexer.start
      monitor.start
    }
  end
end

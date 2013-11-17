require 'eventmachine'

require 'librr/settings'
require 'librr/indexer'
require 'librr/dir_monitor'
require 'librr/cmd_server'

EventMachine.kqueue = true if EventMachine.kqueue?

$indexer = Indexer.new
$monitor = DirMonitor

class Librr::Runner
  def run
    EventMachine.run {
      EventMachine.start_server "127.0.0.1", Settings::RUNNER_PORT, Librr::CmdServer
      $indexer.start
      $monitor.init
    }
  end
end

require 'librr/lib'

module ServerStarter
  extend self

  def run
    require 'daemons'
    require 'librr'
    require 'librr/runner'

    # Daemons.daemonize
    puts "daemon start"
    Librr::Runner.new.run
  end

  def start_server
    Process.fork do
      sess_id = Process.setsid
      Process.fork do
        redirect_std do
          self.run
        end
      end
    end
  end
end

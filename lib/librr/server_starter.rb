# copy from gem daemons file: daemonize.rb
# todo: may has secruity risk
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
        exit
      end
      exit
    end
  end
end

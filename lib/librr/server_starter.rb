# copy from gem daemons file: daemonize.rb
# todo: may has secruity risk
require 'librr/lib'

module ServerStarter
  extend self

  def run
    require 'librr'
    require 'librr/runner'

    Librr::Runner.new.run!
  end

  def start_server(sync)
    puts 'server starting..'
    return self.run if sync

    Process.fork do
      sess_id = Process.setsid
      Process.fork do
        redirect_std do
          puts "daemon start"
          self.run
        end
        exit
      end
      exit
    end
  end
end

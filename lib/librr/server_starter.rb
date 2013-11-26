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
          $logger.info "daemon started."
          self.run
        end
        exit
      end
      exit
    end
  end

  def wait_for_server_started &block
    5.times.each do
      sleep(2)
      puts 'waiting for server starting..'

      if File.exists?(Settings::PID_FILE)
        return block.call if block
      end
    end
    puts "server not starting, something is wrong."
    exit
  end
end

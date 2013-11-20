require 'eventmachine'
require 'rb-fsevent'

module DirMonitor
  DIRS = ['/Users/halida/data/workspace/librr']
  OBJS = {}

  def post_init
    # count up to 5
    # send_data "5\n"
  end

  def receive_data data
    puts "ruby sent me: #{data}"
  end

  def unbind
    puts "ruby died with exit status: #{get_status.exitstatus}"
  end

  def self.start
    @pipe = EM.popen([FSEvent.watcher_path] + DIRS, DirMonitor)
    # EM.add_timer(10){
    #   puts @pipe.class
    #   puts @pipe.methods.to_s
    #   @pipe.close_connection
    # }
  end
end

EventMachine.run {
  DirMonitor.start
}


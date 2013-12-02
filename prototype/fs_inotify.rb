require 'eventmachine'
require 'rb-inotify'


TESTDIR = "/home/halida/workspace/librr_coding/test"


module NotifierClient
  # todo use accessor
  def self.notifier=(notifier)
    @@notifier = notifier
  end

  def notify_readable
    @@notifier.process
  end

  def unbind
    puts "unbind"
  end
end

def modify_file
  puts "modify file"
  file = File.join(TESTDIR, 'test.txt')
  File.open(file, 'a+'){ |f| f.write("hello\n") }
end

def notifier_run(notifier)
  Thread.new { sleep 1; modify_file }
  return notifier.run
end

def select_run(notifier)
  io = notifier.to_io
  Thread.new { sleep 1; modify_file }
  while true
    if IO.select([io], [], [], 10)
      notifier.process
    end
    sleep 0.5
  end
end

def em_run(notifier)
  # should create first, otherwise not working
  io = notifier.to_io
  # puts io.fileno

  NotifierClient.notifier = notifier

  EM.run do
    c = EM.watch io, NotifierClient
    c.notify_readable = true

    EM.add_timer(1) { modify_file }
    puts 'end'
  end
end

def main
  notifier = INotify::Notifier.new
  notifier.watch(TESTDIR, :modify) do |event|
    puts "#{event.name} was modified!"
  end

  # notifier_run(notifier)
  # select_run(notifier)
  em_run(notifier)
end

main

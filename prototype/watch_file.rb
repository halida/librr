require 'eventmachine'

# Before running this example, make sure we have a file to monitor:
# $ echo "bar" > /tmp/foo

module Handler
  def file_modified
    puts "#{path} modified"
  end

  def file_moved
    puts "#{path} moved"
  end

  def file_deleted
    puts "#{path} deleted"
  end

  def unbind
    puts "#{path} monitoring ceased"
  end
end

# for efficient file watching, use kqueue on Mac OS X
EventMachine.kqueue = true if EventMachine.kqueue?

EventMachine.run {
  EventMachine.watch_file(Dir.pwd, Handler)
}

# $ echo "baz" >> /tmp/foo    =>    "/tmp/foo modified"
# $ mv /tmp/foo /tmp/oof      =>    "/tmp/foo moved"
# $ rm /tmp/oof               =>    "/tmp/foo deleted"

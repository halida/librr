require 'eventmachine'
require 'rb-fsevent'

require 'set'

require 'librr/configer'

module DirMonitor
  DIRS = Configer.load_dir_config
  puts "on monitor: #{DIRS.to_a.to_s}"
  OBJS = {}
  @@pipe = nil

  OPTS = ["--file-events"]

  def self.init opts
    @@indexer = opts[:indexer]
  end

  def self.add_directory(dir)
    puts "add directory: #{dir}"
    @@indexer.index_directory(dir)
    DIRS.add(dir)
    Configer.save_dir_config(DIRS)
    puts "save directory: #{DIRS.to_a.to_s}"
    self.start
  end

  def self.remove_directory(dir)
    puts "remove directory: #{dir}"
    DIRS.delete(dir)
    Configer.save_dir_config(DIRS)
    self.start
  end

  def post_init
    # count up to 5
  end

  def receive_data data
    changes = data.strip.split(':').map(&:strip).reject{|s| s == ''}
    changes.each do |file|
      @@indexer.index_file(file)
    end
  end

  def unbind
    puts "stopped monitor process.."
  end

  def self.start
    if DIRS.empty?
      puts "DIR empty, not start process."
      return
    end

    @pipe.close_connection if @pipe
    cmd = [FSEvent.watcher_path] + OPTS + DIRS.to_a
    puts "start monitor process: #{cmd}"
    @pipe = EM.popen(cmd, DirMonitor)
  end
end

module DirWatcher
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

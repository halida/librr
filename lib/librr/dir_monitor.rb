require 'eventmachine'
require 'rb-fsevent'
require 'set'

require 'librr/logger'
require 'librr/configer'


class Librr::DirMonitor
  include Librr::Logger::ClassLogger

  attr_accessor :indexer, :dirs

  def init opts
    @pipe = nil
    @new_start = false
    @indexer = opts[:indexer]

    self.dirs = Configer.load_dir_config
    self.debug "init dirs: #{self.dirs.to_a.to_s}"
  end

  def reindex
    self.debug "reindex"
    @indexer.cleanup
    self.dirs.each do |dir|
      @indexer.index_directory(dir)
    end
  end

  def add_directory(dir)
    self.debug "add dir: #{dir}"
    @indexer.index_directory(dir)
    self.dirs.add(dir)
    Configer.save_dir_config(self.dirs)
    self.debug "save dir: #{self.dirs.to_a.to_s}"
    self.start
  end

  def remove_directory(dir)
    self.debug "remove dir: #{dir}"
    @indexer.remove_index_directory(dir)
    self.dirs.delete(dir)
    Configer.save_dir_config(self.dirs)
    self.start
  end

  def post_init
    @after_block.call if @after_block
  end

  def after_process_stop
    self.start_process if @new_start
    @new_start = false
  end

  def start &after_block
    @after_block = after_block

    if self.dirs.empty?
      self.debug "DIR empty, not start process."
      self.post_init
      return
    end

    if @pipe
      @new_start = true
      @pipe.close_connection
    else
      self.start_process
    end
  end

  def self.pid_file
    Settings.in_dir('dir_watcher.pid')
  end

  def start_process
    kill_process_by_file(self.class.pid_file)

    cmd = [FSEvent.watcher_path] + ["--file-events"] + self.dirs.to_a
    self.debug "start process: #{cmd}"
    @pipe = EM.popen(cmd, DirWatcher, self)
    # TODO: write pid file
  end

  class DirWatcher < EventMachine::Connection
    include Librr::Logger::ClassLogger

    def initialize(monitor)
      super
      @monitor = monitor
    end

    def post_init
      @monitor.post_init
    end

    def receive_data data
      self.debug "on receive data: #{data}"
      changes = data.strip.split(':').map(&:strip).reject{|s| s == ''}
      changes.each do |file|
        @monitor.indexer.index_file(file)
      end
    end

    def unbind
      self.debug "dir monitor process stopped."
      @monitor.after_process_stop
      File.delete Librr::DirMonitor.pid_file rescue nil
    end

  end

end


require 'eventmachine'
require 'rb-fsevent'
require 'set'

require 'librr/logger'
require 'librr/configer'


class Librr::DirMonitor

  attr_accessor :indexer, :dirs

  def init opts
    @pipe = nil
    @new_start = false
    @indexer = opts[:indexer]

    self.dirs = Configer.load_dir_config
    $logger.info(:DirMonitor){ "init dirs: #{self.dirs.to_a.to_s}" }
  end

  def info(text)
    $logger.info(:DirMonitor){ text }
  end

  def reindex
    self.info "reindex"
    @indexer.cleanup
    self.dirs.each do |dir|
      @indexer.index_directory(dir)
    end
  end

  def add_directory(dir)
    self.info "add dir: #{dir}"
    @indexer.index_directory(dir)
    self.dirs.add(dir)
    Configer.save_dir_config(self.dirs)
    self.info "save dir: #{self.dirs.to_a.to_s}"
    self.start
  end

  def remove_directory(dir)
    self.info "remove dir: #{dir}"
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
      self.info "DIR empty, not start process."
      return
    end

    if @pipe
      @new_start = true
      @pipe.close_connection
    else
      self.start_process
    end
  end

  def start_process
    cmd = [FSEvent.watcher_path] + ["--file-events"] + self.dirs.to_a
    self.info "start process: #{cmd}"
    @pipe = EM.popen(cmd, DirWatcher, self)
  end

  class DirWatcher < EventMachine::Connection

    def initialize(monitor)
      super
      @monitor = monitor
    end

    def post_init
      @monitor.post_init
    end

    def receive_data data
      $logger.info(:DirWatcher){ "on receive data: #{data}" }
      changes = data.strip.split(':').map(&:strip).reject{|s| s == ''}
      changes.each do |file|
        @monitor.indexer.index_file(file)
      end
    end

    def unbind
      $logger.info(:DirWatcher){ "dir monitor process stopped." }
      @monitor.after_process_stop
    end

  end

end


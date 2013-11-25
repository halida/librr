require 'eventmachine'
require 'rb-fsevent'
require 'set'

require 'librr/logger'
require 'librr/configer'


class Librr::DirMonitor

  attr_accessor :indexer, :dirs

  def init opts
    @pipe = nil
    @indexer = opts[:indexer]

    self.dirs = Configer.load_dir_config
    $logger.info "on monitor: #{self.dirs.to_a.to_s}"
  end

  def reindex
    @indexer.cleanup
    self.dirs.each do |dir|
      @indexer.index_directory(dir)
    end
  end

  def add_directory(dir)
    $logger.info "add directory: #{dir}"
    @indexer.index_directory(dir)
    self.dirs.add(dir)
    Configer.save_dir_config(self.dirs)
    $logger.info "save directory: #{self.dirs.to_a.to_s}"
    self.start
  end

  def remove_directory(dir)
    $logger.info "remove directory: #{dir}"
    @indexer.remove_index_directory(dir)
    self.dirs.delete(dir)
    Configer.save_dir_config(self.dirs)
    self.start
  end

  def post_init
    @after_block.call if @after_block
  end

  def start &after_block
    @after_block = after_block

    if self.dirs.empty?
      $logger.info "DIR empty, not start process."
      return
    end

    @pipe.close_connection if @pipe
    cmd = [FSEvent.watcher_path] + ["--file-events"] + self.dirs.to_a
    $logger.info "start monitor process: #{cmd}"
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
      changes = data.strip.split(':').map(&:strip).reject{|s| s == ''}
      changes.each do |file|
        @monitor.indexer.index_file(file)
      end
    end

    def unbind
      $logger.info "dir monitor process stopped."
    end

  end

end


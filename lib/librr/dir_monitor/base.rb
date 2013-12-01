require 'librr/configer'

module Librr::DirMonitor

  class Base
    include Librr::Logger::ClassLogger

    attr_accessor :indexer, :dirs

    def init opts
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

    def start &after_block
      raise NotImplementedError
    end

  end
end

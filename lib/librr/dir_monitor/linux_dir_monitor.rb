require 'rb-inotify'

require 'librr/dir_monitor/base'


class LinuxDirMonitor < Librr::DirMonitor::Base

  module NotifierConnector
    def self.notifier=(notifier)
      @@notifier = notifier
    end

    def notify_readable
      @@notifier.process
    end
  end


  def init(opts)
    super(opts)
    @notifier = nil
  end

  def start &after_block

    self.stop_notifier

    @notifier = INotify::Notifier.new

    if self.dirs.empty?
      self.debug "DIR empty, not start monitoring."
      after_block.call if after_block
      return
    end

    self.dirs.each do |dir|
      @notifier.watch(dir, :modify, :moved_from, :moved_to, :create, :delete) do |event|
        filename = File.join(dir, event.name)
        self.debug "on change file or dir: #{filename}"
        self.on_change(filename)
      end
    end

    NotifierConnector.notifier = @notifier
    io = @notifier.to_io
    @connection = EM.watch io, NotifierConnector
    @connection.notify_readable = true

    after_block.call if after_block
  end

  def stop_notifier
    return unless @notifier

    @connection.detach
    @connection = nil
    @notifier.close
    @notifier = nil
  end

  def on_change(file)
    @indexer.index_file(file)
  end

end

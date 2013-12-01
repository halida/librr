require 'rb-inotify'

require 'librr/dir_monitor/base'


class LinuxDirMonitor < Librr::DirMonitor::Base

  def init(opts)
    super(opts)
    @notifier = nil
  end

  def start &after_block

    self.stop_notifier if @notifier

    @notifier = INotify::Notifier.new

    if self.dirs.empty?
      self.debug "DIR empty, not start monitoring."
      after_block.call
      return
    end

    notifier.watch("path/to/foo.txt", :modify) do |event|
      self.debug "on change file or dir: #{event.name}"
      self.on_change(event.name)
    end

    EM.watch notifier.to_io do
      notifier.process
    end

    after_block.call
  end

  def stop_notifier
    EM.detach notifier.to_io
  end

  def on_change(file)
    @monitor.indexer.index_file(file)
  end

end

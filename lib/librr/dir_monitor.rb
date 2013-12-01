module Librr::DirMonitor

  def self.get_monitor
    case os
    when :macosx
      require 'librr/dir_monitor/osx_dir_monitor'
      OsxDirMonitor.new
    when :linux
      require 'librr/dir_monitor/linux_dir_monitor'
      LinuxDirMonitor.new
    else
      require 'librr/dir_monitor/none_dir_monitor'
      NoneDirMonior.new
    end
  end

end

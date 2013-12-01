require 'librr/dir_monitor/base'


class OsxDirMonitor < Librr::DirMonitor::Base

    def start &after_block
      self.warn "unsupported platform: #{RUBY_PLATFORM}, monitor disabled."
      after_block.call if after_block
    end

end

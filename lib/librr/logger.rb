require 'logger'
require 'singleton'


class Librr::Logger
  include Singleton

  module ClassLogger
    def logger
      Librr::Logger.instance.logger
    end

    def info(text)
      self.logger.info(self.class.name){ text }
    end

    def debug(text)
      self.logger.debug(self.class.name){ text }
    end
  end

  def logger
    @logger ||= self.create_logger
  end

  def logger=(logger)
    @logger = logger
  end

  def create_logger
    logger = Logger.new(STDOUT)
    logger.level = Logger::WARN
    logger
  end

  def set_level level
    self.logger.level = level
  end

end

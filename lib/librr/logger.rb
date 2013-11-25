require 'logger'

class Librr::Logger

  def self.create_logger
    logger = Logger.new(STDOUT)
    # logger.level = Logger::WARN
    logger.level = Logger::DEBUG
    logger
  end

end

$logger ||= Librr::Logger.create_logger


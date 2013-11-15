require 'thor'

class Librr::CMD < Thor

  desc 'start', 'start background process'
  def start
    puts 'starting..'
    # todo
  end

  desc 'stop', 'stop background process'
  def stop
    puts 'stopping..'
    # todo
  end

  desc 'add DIR', 'add directory for indexing'
  def add(dir)
    puts "indexing: #{dir}"
    # todo
  end

  desc 'remove DIR', 'remove directory from indexing'
  def remove(dir)
    puts "removing: #{dir}"
    # todo
  end

  desc 'list', 'list all indexed directories'
  def list
    # todo
  end

  desc 'search STRING', 'search emacs'
  def search(str)
    puts "searching: #{str}"
  end

  def self.run!
    self.start(ARGV)
  end
end

require 'thor'
require 'librr/cmd_client'
require 'librr/settings'

class Librr::CMD < Thor
  @@client = CmdClient.new('localhost', Settings::RUNNER_PORT)

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
    @@client.cmd(:add, dir: File.expand_path(dir))
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

  desc "reindex", "reindex files"
  def reindex
    @@client.cmd(:reindex)
  end

  desc 'search STRING', 'search emacs'
  def search(text)
    puts "searching: #{text}"
    results = @@client.cmd(:search, text: text)
    if results.empty?
      puts "cannot find any result"
    else
      puts results.map{|v| v.join(":")}
    end
  end

  def self.run!
    self.start(ARGV)
  end
end

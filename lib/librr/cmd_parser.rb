require 'thor'
require 'librr/cmd_client'
require 'librr/settings'


class Librr::CmdParser < Thor

  option :sync, type: :boolean
  desc 'daemon_start [--sync]', 'start background daemon process'
  def daemon_start
    if @@client.check_start(options[:sync])
      puts 'daemon already started..'
    end
  end

  desc 'daemon_stop', 'stop background daemon process'
  def daemon_stop
    puts 'stopping daemon..'
    @@client.cmd(:stop) rescue nil
  end

  desc 'add DIR', 'add directory for indexing'
  def add(dir)
    puts "indexing: #{dir}"
    @@client.cmd(:add, dir: File.expand_path(dir))
  end

  desc 'remove DIR', 'remove directory from indexing'
  def remove(dir)
    puts "removing: #{dir}"
    @@client.cmd(:remove, dir: File.expand_path(dir))
  end

  desc 'list', 'list all indexed directories'
  def list
    puts @@client.cmd(:list)
  end

  desc "reindex", "reindex files"
  def reindex
    @@client.cmd(:reindex)
  end

  option :rows, type: :numeric, default: 20
  option :all, type: :boolean
  option :location, type: :string, aliases: "-l"
  desc 'search STRING', 'search string'
  def search(text)
    location = (File.expand_path(options[:location]) if options[:location])
    puts "searching: #{text}"
    results = @@client.cmd(:search,
                       text: text,
                       all: options[:all],
                       rows: options[:rows],
                       location: location,
                       )
    if results.empty?
      puts "find no result"
    else
      puts results.map{|v| v.join(":")}
    end
  end

  def self.run!
    @@client = Librr::CmdClient.new('localhost', Settings.runner_port)
    self.start(ARGV)
  end

end

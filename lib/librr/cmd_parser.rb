require 'thor'
require 'librr/cmd_client'
require 'librr/settings'


class Librr::CmdParser < Thor

  class << self
    attr_accessor :client
  end

  class Daemon < Thor
    option :sync, type: :boolean
    desc 'start [--sync]', 'start background daemon process'
    def start
      if Librr::CmdParser.client.check_start(options[:sync])
        puts 'daemon already started..'
      end
    end

    desc 'stop', 'stop background daemon process'
    def stop
      puts 'stopping daemon..'
      Librr::CmdParser.client.cmd(:stop) rescue nil
    end

    desc 'restart', 'restart background daemon process'
    def restart
      puts 'daemon restarting..'
      Librr::CmdParser.client.cmd(:restart) rescue nil
    end
  end

  desc "daemon SUBCOMMAND ...ARGS", "manage background daemon process"
  subcommand "daemon", Daemon

  desc 'add DIR', 'add directory for indexing'
  def add(dir)
    puts "indexing: #{dir}"
    self.class.client.cmd(:add, dir: File.expand_path(dir))
  end

  desc 'remove DIR', 'remove directory from indexing'
  def remove(dir)
    puts "removing: #{dir}"
    self.class.client.cmd(:remove, dir: File.expand_path(dir))
  end

  desc 'list', 'list all indexed directories'
  def list
    puts self.class.client.cmd(:list)
  end

  desc "reindex", "reindex files"
  def reindex
    self.class.client.cmd(:reindex)
  end

  option :rows, type: :numeric, default: 20
  option :all, type: :boolean
  option :location, type: :string, aliases: "-l"
  desc 'search STRING', 'search string'
  def search(text)
    location = (File.expand_path(options[:location]) if options[:location])
    puts "searching: #{text}"
    results = self.class.client.cmd(:search,
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
    self.client = Librr::CmdClient.new('localhost', Settings.runner_port)
    self.start(ARGV)
  end

end

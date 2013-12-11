require 'librr/cmd_client'
require 'librr/settings'
require 'librr/my_thor'
require 'librr/displayer'
require 'librr/colorize'


class Librr::CmdParser < MyThor
  include Librr::Displayer

  class << self
    attr_accessor :client
  end

  class Daemon < MyThor
    include Librr::Displayer

    option :sync, type: :boolean, aliases: "-s"
    desc 'start [--sync]', 'start background daemon process'
    def start
      Librr::CmdParser.client.start(options[:sync])
    end

    desc 'stop', 'stop background daemon process'
    def stop
      self.show 'stopping daemon..'
      Librr::CmdParser.client.stop
    end

    # desc 'restart', 'restart background daemon process'
    # def restart
    #   self.show 'daemon restarting..'
    #   Librr::CmdParser.client.cmd(:restart) rescue nil
    # end
  end

  desc "daemon SUBCOMMAND ...ARGS", "manage background daemon process"
  subcommand "daemon", Daemon


  desc 'add DIR', 'add directory for indexing'
  def add(dir)
    self.show "adding: #{dir}"
    self.class.client.cmd(:add, dir: File.expand_path(dir))
  end

  desc 'remove DIR', 'remove directory from indexing'
  def remove(dir)
    self.show "removing: #{dir}"
    self.class.client.cmd(:remove, dir: File.expand_path(dir))
  end

  desc 'list', 'list all indexed directories'
  def list
    self.show self.class.client.cmd(:list)
  end

  desc "reindex", "reindex files"
  def reindex
    self.class.client.cmd(:reindex)
  end

  option :rows, type: :numeric, default: 20, aliases: "-r"
  option :all, type: :boolean, aliases: "-a"
  option :location, type: :string, aliases: "-l"
  option :color, type: :boolean, aliases: "-c", default: true
  desc 'search STRING [--location DIR]', 'search string'
  def search(text)
    location = (File.expand_path(options[:location]) if options[:location])
    self.show "searching: #{text}"
    results = self.class.client.cmd(:search,
                                text: text,
                                all: options[:all],
                                rows: options[:rows],
                                location: location,
                                highlight: options[:color],
                          )

    if results.empty?
      self.show "found no result"
      return
    end

    results.each do |d|
      if options[:color]
        filename = Colorize.set d['filename'], :green
        linenum = Colorize.set d['linenum'], :yellow
        line = d['highlight'].gsub(/<librr_em>(?<m>.+)<\/librr_em>/) do |match|
          Colorize.set $1, :red
        end
      else
        filename = d['filename']
        linenum = d['linenum']
        line = d['line']
      end
      self.show "#{filename}:#{linenum}:#{line}"
    end
  end

  def self.run!
    self.client = Librr::CmdClient.new('localhost', Settings.runner_port)
    self.start(ARGV)
  end

end

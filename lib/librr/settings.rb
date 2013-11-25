require 'yaml'

class Settings
  CONFIG_PATH = File.expand_path('~/.librr/')
  CONFIG_FILE = File.join(CONFIG_PATH, 'config')
  PID_FILE = File.join(CONFIG_PATH, 'server.pid')

  DEFAULTS = {
    runner_port: 4512,
    config_path: CONFIG_PATH,
    escape_files: /[#~]$|^\./,
    solr_port: 8901,
  }

  def self.reload
    if File.exists?(CONFIG_FILE)
      begin
        @@config = YAML.load File.read(CONFIG_FILE)
        raise unless @@config.kind_of?(Hash)
      rescue
        raise "config file format error: #{CONFIG_FILE}"
      end
    else
      @@config = DEFAULTS.dup
    end
  end

  def self.method_missing(name)
    self.reload unless defined?(@@config)

    if @@config.include?(name)
      @@config[name]
    else
      super
    end
  end
end

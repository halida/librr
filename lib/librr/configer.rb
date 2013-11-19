require 'librr/settings'

module Configer

  extend self

  def check_config_dir
    conf_path = Settings::CONFIG_PATH
    FileUtils.mkpath(conf_path) unless File.directory?(conf_path)
    conf_path
  end

  def self.load_dir_config
    conf_path = self.check_config_dir

    dc_file = File.join(conf_path, 'dir.conf')
    if File.exists?(dc_file)
      Set.new(File.read(dc_file).split("\n")).delete("")
    else
      []
    end
  end

  def self.save_dir_config(config)
    conf_path = self.check_config_dir

    dc_file = File.join(conf_path, 'dir.conf')
    File.write(dc_file, config.to_a.join("\n"))
  end

end

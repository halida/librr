require 'librr/settings'

module Configer

  extend self

  FILENAME = 'dir.conf'

  def check_config_dir
    conf_path = Settings::CONFIG_PATH
    FileUtils.mkpath(conf_path) unless File.directory?(conf_path)
    conf_path
  end

  def self.load_dir_config
    conf_path = self.check_config_dir

    dc_file = Settings.in_dir(FILENAME)
    if File.exists?(dc_file)
      Set.new(File.read(dc_file).split("\n")).delete("")
    else
      []
    end
  end

  def self.save_dir_config(config)
    conf_path = self.check_config_dir

    dc_file = Settings.in_dir(FILENAME)
    File.write(dc_file, config.to_a.join("\n"))
  end

end

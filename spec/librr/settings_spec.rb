require 'spec_helper'

require 'librr/settings'

describe Settings do
  before do
    FileUtils.mkpath(Settings::CONFIG_PATH)
  end

  after do
    File.delete(Settings::CONFIG_FILE) rescue nil
  end

  it 'default config' do
    File.delete(Settings::CONFIG_FILE) rescue nil
    Settings.runner_port.should == 4512
  end

  it 'load config file' do
    # setting config
    config = Settings::DEFAULTS.dup
    config[:runner_port] = 4545
    File.open(Settings::CONFIG_FILE, 'w+'){ |f| f.write(config.to_yaml) }

    Settings.reload
    Settings.runner_port.should == 4545
  end

  it 'raise error when config file format error' do
    File.open(Settings::CONFIG_FILE, 'w+'){ |f| f.write(':__fdsa__') }
    expect{ Settings.reload }.to raise_error "config file format error: #{Settings::CONFIG_FILE}"
  end
end

require 'spec_helper'
require 'fileutils'

require 'librr/server_controller'


describe ServerController do
  before do
    File.delete Settings::PID_FILE rescue nil
  end

  after do
    File.delete Settings::PID_FILE rescue nil
  end

  describe :start_server do
    it 'create a daemon' do
      # daemon should set log file, and log level
      pending
    end

    it 'run sync' do
      # set log level
      pending
    end

  end

  describe :wait_for_started do
    it 'waiting, if server started, call after' do
      FileUtils.touch(Settings::PID_FILE)
      described_class.stub(:sleep)
      wrong = false
      after = true
      described_class.wait_for_started(proc{}, proc{after = true}, proc{ wrong = true})
      after.should == true
    end

    it 'waiting, if not started, call wrong' do
      wrong = false
      sleep_time = 0
      described_class.stub(:sleep){ sleep_time += 1 }
      described_class.stub(:exit)

      described_class.wait_for_started(proc{}, proc{}, proc{ wrong = true})
      # wait for 10 times
      sleep_time.should == 10
      wrong.should == true
    end
  end

  describe :wait_for_stopped do
    it 'waiting, if server stopped, call after' do
      described_class.stub(:sleep)
      wrong = false
      after = true
      described_class.wait_for_stopped(proc{}, proc{after = true}, proc{ wrong = true})
      after.should == true
    end

    it 'waiting, if not stopped, call wrong' do
      FileUtils.touch(Settings::PID_FILE)
      wrong = false
      sleep_time = 0
      described_class.stub(:sleep){ sleep_time += 1 }
      described_class.stub(:exit)

      described_class.wait_for_stopped(proc{}, proc{}, proc{ wrong = true})
      # wait for 10 times
      sleep_time.should == 10
      wrong.should == true
    end
  end
end

require 'spec_helper'

require 'librr/cmd_client'


describe Librr::CmdClient do
  before do
    @c = Librr::CmdClient.new('localhost', 8888)
  end

  describe :check_start do
    it 'check start by call cmd' do
      # started
      @c.stub(:run_cmd){ |cmd, opt| [cmd, opt] }
      @c.check_start.should == true

      # not started
      @c.stub(:run_cmd){ |cmd, opt| raise Errno::ECONNREFUSED }
      ServerStarter.stub(:start_server){}
      ServerStarter.stub(:wait_for_server_started){ 'waiting' }
      @c.check_start.should == false
    end
  end

  describe :cmd do
    it 'handle cmd' do
      @c.stub(:run_cmd){ |cmd, opt| [cmd, opt] }
      @c.cmd(:remove, dir: '/usr').should == [:remove, {dir: "/usr"}]
    end

    it 'auto start server' do
      @c.stub(:run_cmd){ |cmd, opt| raise Errno::ECONNREFUSED }
      ServerStarter.stub(:start_server){}
      ServerStarter.stub(:wait_for_server_started){ 'waiting' }
      @c.cmd(:remove, dir: '/usr').should == 'waiting'
    end
  end

end


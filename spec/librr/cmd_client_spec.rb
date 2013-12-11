require 'spec_helper'

require 'librr/cmd_client'


describe Librr::CmdClient do
  before do
    @c = Librr::CmdClient.new('localhost', 8888)
  end

  describe :cmd do
    it 'handle cmd' do
      @c.stub(:run_cmd){ |cmd, opt| [cmd, opt] }
      @c.cmd(:remove, dir: '/usr').should == [:remove, {dir: "/usr"}]
    end

    it 'auto start server' do
      @c.stub(:run_cmd){ |cmd, opt| raise Errno::ECONNREFUSED }
      ServerController.stub(:start_server){}
      ServerController.stub(:wait_for_started){ 'waiting' }
      @c.cmd(:remove, dir: '/usr').should == 'waiting'
    end
  end

  describe :server_started? do
    it 'return true when run_cmd not fail' do
      @c.stub(:run_cmd){ |cmd, opt| [cmd, opt] }
      @c.server_started?.should == true
    end

    it 'return false when run_cmd failed' do
      @c.stub(:run_cmd){ |cmd, opt| raise Errno::ECONNREFUSED }
      @c.server_started?.should == false
    end
  end

  describe :start do
    it 'first check already started' do
      Librr::Displayer.save_output = true
      @c.stub(:server_started?){true}
      @c.start
      Librr::Displayer.output.should == ["daemon already started.."]
    end

    specify do
      pending
    end
  end

  describe :stop do
    specify do
      pending
    end
  end

end


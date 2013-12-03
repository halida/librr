require 'spec_helper'

require 'librr/lib'
require 'librr/cmd_parser'


# test method learn from:
# https://github.com/erikhuda/thor/blob/master/spec/thor_spec.rb

describe Librr::CmdParser do

  class C
    attr_accessor :result, :on_cmd

    def cmd cmd, args={}
      self.on_cmd = [cmd, args]
      return @result if @result
      self.on_cmd
    end

    def start(sync); [:start, sync]; end
    def stop(); :stop; end

    def with_result(data, &block)
      @result = data
      block.call
      @result = nil
    end
  end

  def cmd args
    Librr::Displayer.clear_output
    result = Librr::CmdParser.start(args)
    @output = Librr::Displayer.output
    result
  end

  before(:all) do
    @c = C.new
    Librr::CmdParser.client = @c
    Librr::Displayer.save_output = true
  end

  describe Librr::CmdParser::Daemon do
    describe :start do
      it 'normal case' do
        cmd(['daemon', 'start']).should == [:start, nil]
      end

      it 'shortcut' do
        cmd(['d', 'start']).should == [:start, nil]
      end

      it 'with sync' do
        cmd(['d', 'start', '--sync']).should == [:start, true]
      end

      it 'sync shortcut' do
        cmd(['d', 'start', '-s']).should == [:start, true]
      end
    end

    describe :stop do
      it 'normal case' do
        cmd(['d', 'stop']).should == :stop
        puts Librr::Displayer.output.to_s
        @output.should == ['stopping daemon..']
      end
    end
  end

  describe :add do
    it 'works' do
      cmd(['add', '/abc']).should == [:add, {dir: "/abc"}]
      @output.should == ['adding: /abc']
    end

    it 'auto expend file path' do
      cmd(['add', '.']).should == [:add, {dir: File.expand_path('.')}]
    end
  end

  describe :remove do
    it 'works' do
      cmd(['remove', '/abc']).should == [:remove, {dir: "/abc"}]
      @output.should == ['removing: /abc']
    end

    it 'auto expend file path' do
      cmd(['remove', '.']).should == [:remove, {dir: File.expand_path('.')}]
    end
  end

  describe :list do
    it 'works' do
      @c.with_result ['/abc', 'def'] do
        cmd(['list'])
        @output.should == [['/abc', 'def']]
      end
    end
  end

  describe :reindex do
    specify do
      cmd(['reindex']).should == [:reindex, {}]
    end
  end

  describe :search do
    before do
      @data = [
        {'filename' => 'a/b.org', 'linenum' => 12, 'line' => 'aaa', 'highlight' => 'aaa'},
        {'filename' => 'c/d.org', 'linenum' => 14, 'line' => 'bbb', 'highlight' => 'bbb'},
      ]
    end

    it 'tell user when no result' do
      @c.with_result [] do
        cmd(['search', 'abc'])
        @output.should == ['searching: abc', 'found no result']
      end
    end

    it 'send default parameters' do
      @c.with_result @data do
        cmd(['search', 'abc'])
        @c.on_cmd.should == \
        [:search, {text: "abc", all: nil, rows: 20, location: nil, highlight: true}]
      end
    end

    it 'sets parameters' do
      @c.with_result @data do
        cmd(['search', 'abc',
              '--rows', '10',
              '--all',
              '--location', '/dir',
              '--color', 'false'])
        @c.on_cmd.should == \
        [:search, {text: "abc", all: true, rows: 10, location: '/dir', highlight: false}]
      end
    end

    it 'sets parameters with shortcut' do
      @c.with_result @data do
        cmd(['search', 'abc', '-r', '10', '-a', '-l', '/dir', '-c', 'false'])
        @c.on_cmd.should == \
        [:search, {text: "abc", all: true, rows: 10, location: '/dir', highlight: false}]
      end
    end

    it 'support shortcut' do
      @c.with_result @data do
        cmd(['s', 'abc'])
      end
      @c.on_cmd[0].should == :search
    end

    it 'works' do
      @c.with_result @data do
        cmd(['search', 'abc']).should == \
        [
          {"filename"=>"a/b.org", "linenum"=>12, "line"=>"aaa", "highlight"=>"aaa"},
          {"filename"=>"c/d.org", "linenum"=>14, "line"=>"bbb", "highlight"=>"bbb"}
        ]
      end
    end

  end

end

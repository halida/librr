require 'spec_helper'

require 'librr/cmd_parser'

# test method learn from:
# https://github.com/erikhuda/thor/blob/master/spec/thor_spec.rb

describe Librr::CmdParser do

  class C
    attr_accessor :result

    def cmd cmd, args={}
      return @result if @result
      [cmd, args]
    end

    def start(sync); end
    def stop; end
  end

  def cmd args
    Librr::CmdParser.start(args)
  end

  before do
    @c = C.new
    Librr::CmdParser.client = @c
  end

  describe Librr::CmdParser::Daemon do
    describe :start do
      specify do
        # normal use
        cmd(['daemon', 'start'])
        cmd(['fuck'])
      end
    end

    describe :stop do
      specify do
        cmd(['stop']).should == nil
      end
    end
  end

  it 'add dir' do
    cmd(['add', '/abc']).should == [:add, {:dir=>"/abc"}]
  end

  it 'remove dir' do
    cmd(['remove', '/abc']).should == [:remove, {:dir=>"/abc"}]
  end

  it 'list dirs' do
    cmd(['list']).should == nil
  end

  it 'reindex' do
    cmd(['reindex']).should == [:reindex, {}]
  end

  it 'search' do
    @c.result = []
    cmd(['search', 'abc']).should == nil

    @c.result = [
      {'filename' => 'a/b.org', 'linenum' => 12, 'line' => 'aaa', 'highlight' => 'aaa'},
      {'filename' => 'c/d.org', 'linenum' => 14, 'line' => 'bbb', 'highlight' => 'bbb'},
    ]
    cmd(['search', 'abc']).should == \
    [{"filename"=>"a/b.org", "linenum"=>12, "line"=>"aaa", "highlight"=>"aaa"}, {"filename"=>"c/d.org", "linenum"=>14, "line"=>"bbb", "highlight"=>"bbb"}]
  end
end

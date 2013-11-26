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

    def check_start(sync)
    end
  end

  def cmd args
    Librr::CmdParser.start(args)
  end

  before do
    @c = C.new
    Librr::CmdParser.class_variable_set :@@client, @c
  end

  it 'start server' do
    cmd(['start']).should == nil
  end

  it 'stop server' do
    cmd(['stop']).should == [:stop, {}]
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

    @c.result = [['a/b.org', 12, 'aaa'], ['c/d.org', 14, 'bbb']]
    cmd(['search', 'abc']).should == nil
  end
end

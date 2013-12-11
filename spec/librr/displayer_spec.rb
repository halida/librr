require 'spec_helper'

require 'librr/displayer'


describe Librr::Displayer do
  class T
    include Librr::Displayer
    def work
      self.show 'work'
    end
  end

  def get_stdout &block
    sio = StringIO.new
    old_stdout, $stdout = $stdout, sio

    block.call

    $stdout = old_stdout
    actual = sio.string
  end

  it 'show text to the stdout' do
    Librr::Displayer.save_output = false
    out = get_stdout do
      T.new.work
    end
    out.should == "work\n"
  end

  it 'redirect show to the output' do
    described_class.save_output = true
    described_class.clear_output
    T.new.work
    described_class.output.should == ['work']
  end

  it 'clears output' do
    described_class.output = 12
    described_class.clear_output
    described_class.output.should == []
  end
end


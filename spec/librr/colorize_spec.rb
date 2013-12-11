require 'spec_helper'

require 'librr/colorize'

describe Colorize do
  describe :set do
    it 'works' do
      Colorize.set('yes', :red).should == "\e[31myes\e[0m"
    end

    it 'error on wrong color' do
      expect{ Colorize.set('yes', :darkblue) }.to raise_error
    end
  end
end


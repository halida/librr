require 'spec_helper'

require 'librr/cmd_server'


describe Librr::CmdServer do

  it 'start after block' do
    cs = Librr::CmdServer.new
    cs.init(monitor: nil, indexer: nil)
    pending
  end

  describe :handle_cmd do
    pending
  end
end


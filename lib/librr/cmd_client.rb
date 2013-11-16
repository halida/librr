require 'net/http'
require 'json'

class CmdClient
  def initialize host, port
    @host = host
    @port = port
  end

  def cmd cmd, **params
    params[:cmd] = cmd
    url = '/cmd'
    result = Net::HTTP.post_form(URI.parse("http://#{@host}:#{@port}#{url}"), params)
    JSON.load(result.body)
  end
end

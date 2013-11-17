require 'eventmachine'
require 'rsolr-async'

rsolr = RSolr.connect(:async, :url => 'http://localhost:8901/solr')

response = rsolr.get 'select', params: {q: '*:*'}

solr.add :id=>1, :price=>1.00

EventMachine.run {
  DirMonitor.start
}

require 'eventmachine'
require 'rsolr-async'

solr = RSolr.connect(:async, :url => 'http://localhost:8901/solr')

# delete all
solr.delete_by_query '*:*'
solr.commit

# add
solr.add id: SecureRandom.uuid, filename: 'ab.rb', linenum: 1, line: 'fdafdsa'
solr.commit

# query
solr.get 'select', params: {q: 'line:daf'}


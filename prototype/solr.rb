require 'rsolr'

solr = RSolr.connect(:async, :url => 'http://localhost:8901/solr')

# delete all
solr.delete_by_query '*:*'
solr.commit

# add
solr.add id: SecureRandom.uuid, filename: 'ab.rb', linenum: 1, line: 'fdafdsa'
solr.commit

# query
solr.get 'select', params: {q: 'line:daf'}
solr.get 'select', params: {q: 'line:librr', hl: true, fl: 'line'}

def fix_encoding text
  # solution copy from:
  # http://stackoverflow.com/questions/11375342/stringencode-not-fixing-invalid-byte-sequence-in-utf-8-error
  text
    .encode('UTF-16', undef: :replace, invalid: :replace, replace: "")
    .encode('UTF-8')
end

# index dir
dir = "/Users/halida/Dropbox/sync/emacs/data/gtd"
Dir.glob(File.join(dir, "**/*")).each do |file|
  next unless File.file?(file)
  next if file =~ /[#~]$|^\./

  if File.exists?(file)
    solr.delete_by_query "filename:#{file}"
    File.readlines(file)
      .map{ |line| fix_encoding(line) }
      .map(&:rstrip).each_with_index do |line, num|
      solr.add id: SecureRandom.uuid, filename: file, linenum: num, line: line
    end
  else
    solr.delete_by_query "filename:#{file}"
  end
  solr.commit
end

# return highlight
solr.get 'select', params: {q: 'line:def', hl: true, "hl.fl" => "line"}

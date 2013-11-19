require 'eventmachine'
require 'rsolr-async' rescue nil

module SolrManager
  def post_init
    puts 'start solr'
  end

  def receive_data data
    puts "receiving solr: #{data}"
    # $indexer.after_start if data =~ /Registered new searcher/
  end

  def unbind
    puts "stop solr"
  end
end

class Indexer
  FILES = {}

  def start
    Dir.chdir File.join(Dir.pwd, 'solr') do
      solr = 'java -jar start.jar'
      EM.popen(solr, SolrManager)
      EM.add_timer(3){ self.after_start }
    end
  end

  def after_start
    puts 'after solr start'
    @solr = RSolr.connect(:async, :url => 'http://localhost:8901/solr')
    @solr.delete_by_query '*:*'
    @solr.commit
  end

  def index_directory(dir)
    Dir.glob(File.join(dir, "**/*")).each do |file|
      next unless File.file?(file)
      self.index_file(file)
    end
  end

  def index_file(file)
    puts "index file: #{file}"
    File.readlines(file).each_with_index do |line, num|
      @solr.add id: SecureRandom.uuid, filename: file, linenum: num, line: line
    end
    @solr.commit
  end

  def search(str)
    result = @solr.get 'select', params: {q: "line:#{str}"}
    result['response']['docs'].map do |row|
      [row['filename'], row['linenum'], row['line']].flatten
    end
  end
end

require File.expand_path('../lib/librr/version', __FILE__)

Gem::Specification.new do |s|
  s.name = "librr"
  s.version = Librr::VERSION
  s.license = "MIT"
  s.summary = "line based personal documentation search system."
  s.description = <<-END
    It is a tool to to index & search your text based documentation system.
    It use solr for fulltext index.
  END

  s.author = "linjunhalida"
  s.email = "linjunhalida@gmail.com"
  s.homepage = "https://github.com/halida/librr"

  s.files = Dir[
            "README.md", "LICENSE", "VERSION",
            "bin/*",
            "lib/**/*.rb",
            "solr/*"
  ]
  s.require_paths = ["lib"]
  s.executables = ["librr"]
  s.extra_rdoc_files = ["README.md", "LICENSE"]

  s.required_ruby_version = '>= 1.9.3'

  s.add_dependency "thor", "~> 0.8"
  s.add_dependency "eventmachine", "~> 1.0"
  s.add_dependency "eventmachine_httpserver_update"
  s.add_dependency "rsolr", "~> 1.0"
  s.add_dependency "rb-fsevent", "~> 0.9"
  s.add_dependency "rb-inotify", "~> 0.9"
  s.add_dependency "rack", "~> 1.0"

  s.add_development_dependency "rake"
  s.add_development_dependency "sass"
  s.add_development_dependency "rspec"
end

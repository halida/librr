require 'rubygems'
require 'rubygems/package'
require File.expand_path('../lib/librr/version', __FILE__)

spec_file = File.expand_path __FILE__ + '/../librr.gemspec'
spec = Gem::Specification.load spec_file

desc "Package as Gem"
task "package:gem" do
  Gem::Package.build spec
end


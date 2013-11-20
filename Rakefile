require 'rubygems'
require 'rubygems/package'
require File.expand_path('../lib/librr/version', __FILE__)

spec_file = File.expand_path __FILE__ + '/../librr.gemspec'
spec = Gem::Specification.load spec_file

desc "Package as Gem"
task "package:gem" do
  Gem::Package.build spec
end

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec) do |spec|
    spec.pattern = 'spec/**/*_spec.rb'
    spec.rspec_opts = ['--color']
  end
  task default: :spec
rescue LoadError
  nil
end

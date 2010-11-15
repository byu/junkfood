require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "junkfood"
  gem.summary = %Q{My mesh of an all-in-one library for disjoint code.}
  gem.description = %Q{My mesh of an all-in-one library for disjoint code.}
  gem.email = "benjaminlyu@gmail.com"
  gem.homepage = "http://github.com/byu/junkfood"
  gem.authors = ["Benjamin Yu"]

  gem.extra_rdoc_files << 'LICENSE'
  gem.extra_rdoc_files << 'NOTICE'
  gem.extra_rdoc_files << 'README.md'

  gem.add_development_dependency "rspec", ">= 2.0.0.beta.19"
  gem.add_development_dependency "yard", "~> 0.6.0"
  gem.add_development_dependency "bundler", "~> 1.0.0"
  gem.add_development_dependency "jeweler", "~> 1.5.0.pre3"
  gem.add_development_dependency "rcov", ">= 0"

  gem.add_runtime_dependency 'activesupport'
  gem.add_runtime_dependency 'json'
  gem.add_runtime_dependency 'mongoid', '~> 2.0.0.beta.18'
  gem.add_runtime_dependency 'wrong'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new

# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{junkfood}
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Benjamin Yu"]
  s.date = %q{2010-11-20}
  s.description = %q{My mesh of an all-in-one library for disjoint code.}
  s.email = %q{benjaminlyu@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
    "NOTICE",
    "README.md"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE",
    "NOTICE",
    "README.md",
    "Rakefile",
    "VERSION",
    "junkfood.gemspec",
    "lib/junkfood.rb",
    "lib/junkfood/adler32.rb",
    "lib/junkfood/adler32_pure.rb",
    "lib/junkfood/assert.rb",
    "lib/junkfood/base32.rb",
    "lib/junkfood/ceb.rb",
    "lib/junkfood/ceb/base_command.rb",
    "lib/junkfood/ceb/base_event.rb",
    "lib/junkfood/ceb/bus.rb",
    "lib/junkfood/ceb/executors.rb",
    "lib/junkfood/ceb/executors/command_executor.rb",
    "lib/junkfood/ceb/executors/delayed_job_command_executor.rb",
    "lib/junkfood/ceb/executors/event_executor.rb",
    "lib/junkfood/one_time.rb",
    "lib/junkfood/paperclip_string_io.rb",
    "lib/junkfood/rack.rb",
    "lib/junkfood/rack/chained_router.rb",
    "lib/junkfood/rack/error.rb",
    "lib/junkfood/rack/sessions.rb",
    "lib/junkfood/settings.rb",
    "spec/.rspec",
    "spec/junkfood/adler32_pure_spec.rb",
    "spec/junkfood/adler32_spec.rb",
    "spec/junkfood/assert_spec.rb",
    "spec/junkfood/base32_spec.rb",
    "spec/junkfood/ceb/base_command_spec.rb",
    "spec/junkfood/ceb/base_event_spec.rb",
    "spec/junkfood/ceb/bus_spec.rb",
    "spec/junkfood/ceb/executors/command_executor_spec.rb",
    "spec/junkfood/ceb/executors/delayed_job_command_executor_spec.rb",
    "spec/junkfood/ceb/executors/event_executor_spec.rb",
    "spec/junkfood/one_time_spec.rb",
    "spec/junkfood/paperclip_string_io_spec.rb",
    "spec/junkfood/rack/chained_router_spec.rb",
    "spec/junkfood/rack/error_spec.rb",
    "spec/junkfood/rack/sessions_spec.rb",
    "spec/junkfood/settings_spec.rb",
    "spec/junkfood_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/byu/junkfood}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{My mesh of an all-in-one library for disjoint code.}
  s.test_files = [
    "spec/junkfood/adler32_pure_spec.rb",
    "spec/junkfood/adler32_spec.rb",
    "spec/junkfood/assert_spec.rb",
    "spec/junkfood/base32_spec.rb",
    "spec/junkfood/ceb/base_command_spec.rb",
    "spec/junkfood/ceb/base_event_spec.rb",
    "spec/junkfood/ceb/bus_spec.rb",
    "spec/junkfood/ceb/executors/command_executor_spec.rb",
    "spec/junkfood/ceb/executors/delayed_job_command_executor_spec.rb",
    "spec/junkfood/ceb/executors/event_executor_spec.rb",
    "spec/junkfood/one_time_spec.rb",
    "spec/junkfood/paperclip_string_io_spec.rb",
    "spec/junkfood/rack/chained_router_spec.rb",
    "spec/junkfood/rack/error_spec.rb",
    "spec/junkfood/rack/sessions_spec.rb",
    "spec/junkfood/settings_spec.rb",
    "spec/junkfood_spec.rb",
    "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bluecloth>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 2.0.0.beta.22"])
      s.add_development_dependency(%q<yard>, ["~> 0.6.0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.0.pre3"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
      s.add_development_dependency(%q<activesupport>, [">= 0"])
      s.add_development_dependency(%q<json>, [">= 0"])
      s.add_development_dependency(%q<mongoid>, ["~> 2.0.0.beta.18"])
      s.add_development_dependency(%q<wrong>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 2.0.0.beta.19"])
      s.add_development_dependency(%q<yard>, ["~> 0.6.0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.0.pre3"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
      s.add_runtime_dependency(%q<json>, [">= 0"])
      s.add_runtime_dependency(%q<mongoid>, ["~> 2.0.0.beta.18"])
      s.add_runtime_dependency(%q<wrong>, [">= 0"])
    else
      s.add_dependency(%q<bluecloth>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 2.0.0.beta.22"])
      s.add_dependency(%q<yard>, ["~> 0.6.0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.0.pre3"])
      s.add_dependency(%q<rcov>, [">= 0"])
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<mongoid>, ["~> 2.0.0.beta.18"])
      s.add_dependency(%q<wrong>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 2.0.0.beta.19"])
      s.add_dependency(%q<yard>, ["~> 0.6.0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.0.pre3"])
      s.add_dependency(%q<rcov>, [">= 0"])
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<mongoid>, ["~> 2.0.0.beta.18"])
      s.add_dependency(%q<wrong>, [">= 0"])
    end
  else
    s.add_dependency(%q<bluecloth>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 2.0.0.beta.22"])
    s.add_dependency(%q<yard>, ["~> 0.6.0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.0.pre3"])
    s.add_dependency(%q<rcov>, [">= 0"])
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<mongoid>, ["~> 2.0.0.beta.18"])
    s.add_dependency(%q<wrong>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 2.0.0.beta.19"])
    s.add_dependency(%q<yard>, ["~> 0.6.0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.0.pre3"])
    s.add_dependency(%q<rcov>, [">= 0"])
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<mongoid>, ["~> 2.0.0.beta.18"])
    s.add_dependency(%q<wrong>, [">= 0"])
  end
end


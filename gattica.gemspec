# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "gattica"
  s.version = "1.5.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Martijn Scheijbeler, Christopher Le, et all"]
  s.date = "2013-11-29"
  s.description = "Gattica is a easy to use Ruby Gem for getting data from the Google Analytics API.  It supports metrics, dimensions, sort, filters, goals, and segments.  It can handle accounts with 1000+ profiles, and can return data in CSV, Hash, or JSON"
  s.email = "martijn@thenextweb.com"
  s.executables = ["gattica_get_access_token"]
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.files = [
    "Gemfile",
    "Gemfile.lock",
    "LICENSE",
    "README.md",
    "Rakefile",
    "VERSION.yml",
    "bin/gattica_get_access_token",
    "gattica.gemspec",
    "lib/gattica.rb",
    "lib/gattica/account.rb",
    "lib/gattica/convertible.rb",
    "lib/gattica/data_set.rb",
    "lib/gattica/custom_metric.rb",
    "lib/gattica/custom_dimension.rb",
    "lib/gattica/engine.rb",
    "lib/gattica/exceptions.rb",
    "lib/gattica/experiment.rb",
    "lib/gattica/filter.rb",
    "lib/gattica/goals.rb",
    "lib/gattica/hash_extensions.rb",
    "lib/gattica/meta_data.rb",
    "lib/gattica/profile.rb",
    "lib/gattica/property.rb",
    "lib/gattica/segment.rb",
    "lib/gattica/settings.rb",
    "lib/gattica/variant.rb",
    "test/helper.rb",
    "test/settings.rb",
    "test/suite.rb",
    "test/test_engine.rb",
    "test/test_results.rb"
  ]
  s.homepage = "http://github.com/martijnsch/gattica"
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.3"
  s.summary = "Gattica is a easy to use Ruby Gem for getting data from the Google Analytics API."

end

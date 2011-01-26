# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'guides/version'

Gem::Specification.new do |s|
  s.name        = "guides"
  s.version     = Guides::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Yehuda Katz"]
  s.email       = ["wycats@gmail.com"]
  s.homepage    = "http://yehudakatz.com"
  s.summary     = %q{Extracting the Rails Guides framework for the rest of us}
  s.description = %q{A tool for creating version controlled guides for open source projects, based on the Rails Guides framework}

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "guides"

  s.add_dependency "actionpack", "~> 3.0.0"
  s.add_dependency "activesupport", "~> 3.0.0"
  s.add_dependency "rack", "~> 1.2.1"
  s.add_dependency "RedCloth", "~> 4.1.1"
  s.add_dependency "maruku", "~> 0.6.0"
  s.add_dependency "thor", "~> 0.14.6"
  s.add_dependency "thin", "~> 1.2.7"

  s.files              = `git ls-files`.split("\n")
  s.test_files         = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables        = %w(guides)
  s.default_executable = "guides"
  s.require_paths      = ["lib"]
end


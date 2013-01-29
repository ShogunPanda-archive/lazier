# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require File.expand_path('../lib/lazier/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name = "lazier"
  gem.version = Lazier::Version::STRING
  gem.homepage = "http://github.com/ShogunPanda/lazier"
  gem.summary = %q{Several Ruby object enhancements.}
  gem.description = %q{Several Ruby object enhancements.}
  gem.rubyforge_project = "lazier"

  gem.authors = ["Shogun"]
  gem.email = ["shogun_panda@me.com"]

  gem.files = `git ls-files`.split($\)
  gem.executables = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency("json", "~> 1.7.6")
  gem.add_dependency("actionpack", ">= 3.2.11") # We don't use ~> to enable use with 4.0
  gem.add_dependency("tzinfo", "~> 0.3.35")
  gem.add_dependency("r18n-desktop", "~> 1.1.3")

  gem.add_development_dependency("rspec", "~> 2.12.0")
  gem.add_development_dependency("rake", "~> 10.0.3")
  gem.add_development_dependency("simplecov", "~> 0.7.1")
  gem.add_development_dependency("pry", ">= 0")
  gem.add_development_dependency("yard", "~> 0.8.3")
  gem.add_development_dependency("redcarpet", "~> 2.2.2")
  gem.add_development_dependency("github-markup", "~> 0.7.5")
end

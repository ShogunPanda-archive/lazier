# encoding: utf-8
#
# This file is part of the cowtech-extensions gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require File.expand_path('../lib/cowtech-extensions/version', __FILE__)

Gem::Specification.new do |gem|
	gem.name = "cowtech-extensions"
	gem.version = Cowtech::Extensions::Version::STRING
  gem.homepage = "http://github.com/ShogunPanda/cowtech-extensions"
  gem.summary = %q{Several Ruby object enhancementa.}
  gem.description = %q{Several Ruby object enhancements.}
  gem.rubyforge_project = "cowtech-extensions"

  gem.authors = ["Shogun"]
	gem.email = ["shogun_panda@me.com"]

  gem.files = `git ls-files`.split($\)
  gem.executables = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

	gem.add_dependency("actionpack", "~> 3.0")
  gem.add_dependency("tzinfo", "~> 0.3.33")

  gem.add_development_dependency("rspec", "~> 2.10")
  gem.add_development_dependency("rcov", "~> 1.0.0")
  gem.add_development_dependency("pry", "~> 0.9.9")
end

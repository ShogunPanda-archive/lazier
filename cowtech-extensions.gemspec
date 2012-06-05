# encoding: utf-8
#
# This file is part of the cowtech-extensions gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "./lib/cowtech-extensions/version"

Gem::Specification.new do |s|
	s.name = "cowtech-extensions"
	s.version = Cowtech::Extensions::Version::STRING
	s.authors = ["Shogun"]
	s.email = ["shogun_panda@me.com"]
	s.homepage = "http://github.com/ShogunPanda/cowtech-extensions"
	s.summary = %q{Several Ruby object enhancements.}
	s.description = %q{Several Ruby object enhancements.}

	s.rubyforge_project = "cowtech-extensions"
	s.files = `git ls-files`.split("\n")
	s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
	s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
	s.require_paths = ["lib"]

	s.add_dependency("actionpack", "~> 3.0")
end

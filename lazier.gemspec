# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require File.expand_path('../lib/lazier/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name = "lazier"
  gem.version = Lazier::Version::STRING
  gem.homepage = "http://sw.cow.tc/lazier"
  gem.summary = %q{Several Ruby object enhancements.}
  gem.description = %q{Several Ruby object enhancements.}
  gem.rubyforge_project = "lazier"

  gem.authors = ["Shogun"]
  gem.email = ["shogun_panda@me.com"]

  gem.files = `git ls-files`.split($\)
  gem.executables = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 1.9.3"

  gem.add_dependency("json", "~> 1.8.0")
  gem.add_dependency("actionpack", ">= 3.2.13") # We don't use ~> to enable use with 4.0
  gem.add_dependency("tzinfo", ">= 0.3.37") # We don't use ~> to enable use with 0.3.37 (required by activesupport 4.0) and 1.x, which is the latest available
  gem.add_dependency("r18n-desktop", "~> 1.1.5")
  gem.add_dependency("hashie", "~> 2.0.5")
end

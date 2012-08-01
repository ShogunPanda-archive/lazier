# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2012 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "rubygems"
require "coverage_helper"
require "bundler/setup"
require "lazier"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
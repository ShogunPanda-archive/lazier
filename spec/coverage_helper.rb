# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "simplecov"
require "pathname"

if ENV["COWTECH_EXTENSIONS_COVERAGE"] == "TRUE" then
  root = Pathname.new(File.dirname(__FILE__)) + ".."

  SimpleCov.start do
    add_filter do |src_file|
      path = Pathname.new(src_file.filename).relative_path_from(root).to_s
      path !~ /^lib/
    end
  end
end
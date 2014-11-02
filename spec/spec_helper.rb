#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "bundler/setup"
require File.dirname(__FILE__) + "/../lib/lazier"

::I18n.enforce_available_locales = false
Lazier::I18n.default_locale = :en

# encoding: utf-8
#
# This file is part of the cowtech-extensions gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "active_support"

module Cowtech
	module Extensions
		module Version
			MAJOR = 1
			MINOR = 6
			PATCH = 0

			STRING = [MAJOR, MINOR, PATCH].compact.join(".")
		end
	end
end

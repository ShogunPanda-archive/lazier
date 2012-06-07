# encoding: utf-8
#
# This file is part of the cowtech-extensions gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Cowtech
	module Extensions
		module Boolean
			extend ActiveSupport::Concern

      included do
        cattr_accessor :boolean_names
      end

			def to_i
				(self == true) ? 1 : 0
			end

			def value
				self
			end
		end
	end
end
# encoding: utf-8
#
# This file is part of the cowtech-extensions gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Cowtech
	module Extensions
		module Math
			extend ActiveSupport::Concern

			module ClassMethods
				def min(*args)
          args = args.ensure_array.flatten

          if args.length > 0 then
            rv = args[0]
            args.each do |a| rv = a if a < rv end
          else
            rv = nil
          end

          rv
        end

        def max(*args)
          args = args.ensure_array.flatten

          if args.length > 0 then
            rv = args[0]
            args.each do |a| rv = a if a > rv end
          else
            rv = nil
          end

          rv
        end

      end
		end
	end
end
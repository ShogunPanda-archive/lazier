# encoding: utf-8
#
# This file is part of the cowtech-extensions gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Cowtech
	module Extensions
    # Utility methods for Math module.
		module Math
			extend ::ActiveSupport::Concern

      # General methods.
			module ClassMethods
        # Returns the minimum value in the arguments
        #
        # @param args [Array] A collection of object to compare (with the `<` operator).
        # @return [Object] The minimum value or `nil` (if the collection is empty).
				def min(*args)
          rv = nil

          args = args.ensure_array.flatten
          if args.length > 0 then
            rv = args[0]
            args.each do |a| rv = a if a < rv end
          end

          rv
        end

        # Returns the maximum value in the arguments
        #
        # @param args [Array] A collection of object to compare (with the `>` operator).
        # @return [Object] The maximum value or `nil` (if the collection is empty).
        def max(*args)
          rv = nil

          args = args.ensure_array.flatten
          if args.length > 0 then
            rv = args[0]
            args.each do |a| rv = a if a > rv end
          end

          rv
        end
      end
		end
	end
end
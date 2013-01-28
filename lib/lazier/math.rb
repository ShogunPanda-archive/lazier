# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Lazier
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
        args.ensure_array.flatten.min
      end

      # Returns the maximum value in the arguments
      #
      # @param args [Array] A collection of object to compare (with the `>` operator).
      # @return [Object] The maximum value or `nil` (if the collection is empty).
      def max(*args)
        args.ensure_array.flatten.max
      end
    end
  end
end
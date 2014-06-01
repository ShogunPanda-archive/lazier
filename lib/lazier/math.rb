#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
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
      # @param args [Array] A list of objects to compare (with the `<` operator).
      # @return [Object] The minimum value or `nil` (if the list is empty).
      def min(*args)
        args.ensure_array(default: [], no_duplicates: true, compact: true, flatten: true).min
      end

      # Returns the maximum value in the arguments
      #
      # @param args [Array] A list of objects to compare (with the `>` operator).
      # @return [Object] The maximum value or `nil` (if the list is empty).
      def max(*args)
        args.ensure_array(default: [], no_duplicates: true, compact: true, flatten: true).max
      end
    end
  end
end

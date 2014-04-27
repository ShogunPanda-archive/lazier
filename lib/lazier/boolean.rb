# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Lazier
  # Extension for the boolean values.
  module Boolean
    extend ::ActiveSupport::Concern

    # Converts the boolean to an integer.
    #
    # @return [Fixnum] `1` for `true`, `0` for `false`.
    def to_i
      is_a?(TrueClass) ? 1 : 0
    end

    # Returns the boolean itself for use in form helpers.
    #
    # @return [Boolean] The boolean value.
    def value
      self
    end
  end
end

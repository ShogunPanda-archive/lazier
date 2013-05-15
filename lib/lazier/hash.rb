# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Lazier
  # Extensions for Hash objects.
  module Hash
    extend ::ActiveSupport::Concern

    # TODO@PI: deep_symbolize_keys

    # TODO@PI: deep_stringify_keys

    # Returns an HashWithIndifferentAccess based on this hash.
    #
    # @return [HashWithIndifferentAccess] The new HashWithIndifferentAccess object.
    # TODO@PI: Test me
    def indifferentiate
      HashWithIndifferentAccess.new(self)
    end
  end
end
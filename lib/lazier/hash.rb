# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Lazier
  # Extensions for Hash objects.
  module Hash
    extend ::ActiveSupport::Concern

    # Returns an hash making sure that it and all its hash values have indifferent access.
    #
    # @param complete [Boolean] If even value must be deeply made with indifferent access.
    # @return [HashWithIndifferentAccess] The new HashWithIndifferentAccess object.
    # TODO@PI: Test me
    def with_deep_indifferent_access(complete = true)
      method = complete ? :with_deep_indifferent_access : :with_indifferent_access

      inject(HashWithIndifferentAccess.new) { |rv, (k,v)|
        rv[k] = v.is_a?(Hash) ? v.send(method) : v
        rv
      }
    end
  end
end
# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Lazier
  # Extensions for Hash objects.
  module Hash
    extend ::ActiveSupport::Concern

    # Makes sure that the keys of the hash are accessible in the desired way.
    #
    # @param access [Symbol|NilClass] The requested access for the keys. Can be `:strings`, `:symbols` or `:indifferent`. If `nil` the keys are not modified.
    def ensure_access(access)
      method = {strings: :stringify_keys, symbols: :symbolize_keys, indifferent: :with_indifferent_access}.fetch(access, nil)
      method ? send(method) : self
    end
  end
end
# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Lazier
  # Extensions for Hash objects.
  module Hash
    extend ::ActiveSupport::Concern

    # This is called when the user access a member using dotted notation.
    #
    # @param method [String|Symbol] Key to search.
    # @param args [Array] *Unused.*
    # @param block [Proc] *Unused.*
    # @return [Object] The value for the key.
    def method_missing(method, *args, &block)
     rv = nil

     if self.has_key?(method.to_sym) then
        rv = self[method.to_sym]
     elsif self.has_key?(method.to_s) then
        rv = self[method.to_s]
     else
        rv = ::Hash.method_missing(method, *args, &block)
     end

     rv
    end

    # This is called when the user access a member using dotted notation.
    #
    # @param method [String|Symbol] Key to search.
    # @return [Boolean] `true` if the key exists, `false` otherwise.
    def respond_to?(method)
      (self.has_key?(method.to_sym) || self.has_key?(method.to_s)) ? true : ::Hash.respond_to?(method)
    end
  end
end
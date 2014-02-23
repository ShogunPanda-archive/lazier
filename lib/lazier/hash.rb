# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Lazier
  # Extensions for Hash objects.
  module Hash
    # The supported accesses for #ensure_access
    VALID_ACCESSES = {
      strings: :stringify_keys,
      symbols: :symbolize_keys,
      indifferent: :with_indifferent_access,
      dotted: :enable_dotted_access
    }

    extend ::ActiveSupport::Concern

    # Returns a new hash, removing all keys which values are blank.
    #
    # @param validator [Proc], if present all the keys which evaluates to true will be removed. Otherwise all blank values will be removed.
    # @return [Hash] The hash with all blank values removed.
    def compact(&validator)
      validator ||= ->(_, v) { v.blank? }
      reject(&validator)
    end

    # Compacts the current hash, removing all keys which values are blank.
    #
    # @param validator [Proc], if present all the keys which evaluates to true will be removed. Otherwise all blank values will be removed.
    def compact!(&validator)
      validator ||= ->(_, v) { v.blank? }
      reject!(&validator)
    end

    # Makes sure that the keys of the hash are accessible in the desired way.
    #
    # @param accesses [Array] The requested access for the keys. Can be `:strings`, `:symbols` or `:indifferent`. If `nil` the keys are not modified.
    # @return [Hash] The current hash with keys modified.
    def ensure_access(*accesses)
      accesses.compact.inject(self) do |rv, access|
        method = VALID_ACCESSES.fetch(access.ensure_string.to_sym, nil)
        rv = rv.send(method) if method
        rv
      end
    end

    # Makes sure that the hash is accessible using dotted notation. This is also applied to every embedded hash.
    #
    # @param readonly [Boolean] If the dotted notation is only enable for reading. `true` by default.
    # @return [Hash] The current hash with keys enabled for dotted access.
    def enable_dotted_access(readonly = true)
      extend(Hashie::Extensions::MethodReader)
      extend(Hashie::Extensions::MethodQuery)
      extend(Hashie::Extensions::MethodWriter) if !readonly

      each do |_, value|
        if value.is_a?(Hash) then
          value.enable_dotted_access(readonly)
        elsif value.respond_to?(:each) then
          value.each do |element|
            element.enable_dotted_access(readonly) if element.is_a?(Hash)
          end
        end
      end

      self
    end
  end
end
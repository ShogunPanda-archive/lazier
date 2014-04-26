# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Lazier
  # Extensions for all objects.
  module Object
    extend ::ActiveSupport::Concern

    # Expression to match a boolean value.
    BOOLEAN_MATCHER = /^(\s*(1|0|true|false|yes|no|t|f|y|n)\s*)$/i

    # Expression to match a true value.
    BOOLEAN_TRUE_MATCHER = /^(\s*(1|true|yes|t|y)\s*)$/i

    # Expression to match a integer value.
    INTEGER_MATCHER = /^([+-]?)(\d+)$/

    # Expression to match a float value.
    FLOAT_MATCHER = /^([+-]?)(\d+)([.,]\d+)?$/

    # Normalizes a number for conversion. Basically this methods removes all separator and ensures that `.` is used for decimal separator.
    #
    # @return [String] The normalized number.
    def normalize_number
      is_boolean? ? to_i.to_s : ensure_string.strip.gsub(/[\.,](?=(.*[\.,]))/, "").gsub(",", ".")
    end

    # Checks if the object is a valid integer.
    #
    # @return [Boolean] `true` is a valid integer, `false` otherwise.
    def is_integer?
      is_numeric?(Integer, ::Lazier::Object::INTEGER_MATCHER)
    end

    # Checks if the object is a valid float.
    #
    # @return [Boolean] `true` is a valid float, `false` otherwise.
    def is_float?
      is_numeric?(Numeric, ::Lazier::Object::FLOAT_MATCHER)
    end

    # Checks if the object is of a numeric class of matches a numeric string expression.
    #
    # @return [Boolean] `true` is a valid numeric object, `false` otherwise.
    def is_numeric?(klass = Integer, matcher = ::Lazier::Object::INTEGER_MATCHER)
      is_a?(klass) || is_a?(::TrueClass) || !self || normalize_number =~ matcher
    end

    alias :is_number? :is_float?

    # Checks if the object is a valid boolean value.
    #
    # @return [Boolean] `true` is a valid boolean value, `false` otherwise.
    def is_boolean?
      is_a?(::TrueClass) || !self || to_s =~ ::Lazier::Object::BOOLEAN_MATCHER
    end

    # Sends a method to the object. If the objects doesn't not respond to the method, it returns `nil` instead of raising an exception.
    #
    # @param method [Symbol] The method to send.
    # @param args [Array] The arguments to send.
    # @param block [Proc] The block to pass to the method.
    # @return [Object|nil] The return value of the method or `nil`, if the object does not respond to the method.
    def safe_send(method, *args, &block)
      respond_to?(method) ? send(method, *args, &block) : nil
    end

    # Makes sure that the object is set to something meaningful.
    #
    # @param default_value [String] The default value to return if the `verifier` or the block returns true.
    # @param verifier [Symbol] The method used to verify if the object is NOT meaningful. *Ignored if a block is passed.*
    # @return [String] The current object or the `default_value`.
    def ensure(default_value, verifier = :blank?)
      valid = block_given? ? yield(self) : send(verifier)
      !valid ? self : default_value
    end

    # Makes sure that the object is a string.
    #
    # @param default_value [String] The default value to return if the object is `nil`. It is also passed to the block stringifier.
    # @param stringifier [Symbol] The method used to convert the object to a string. *Ignored if a block is passed.*
    # @return [String] The string representation of the object.
    def ensure_string(default_value = "", stringifier = :to_s)
      !is_a?(NilClass) ? (block_given? ? yield(self, default_value) : send(stringifier)) : default_value
    end

    # Makes sure that the object is an array. For non array objects, return a single element array containing the object.
    #
    # @param default_value [Array|NilClass] The default array to use. If not specified, an array containing the object is returned.
    # @param uniq [Boolean] If to remove duplicates from the array before sanitizing.
    # @param compact [Boolean] If to compact the array before sanitizing.
    # @param flatten [Boolean] If to flatten the array before sanitizing.
    # @param sanitizer [Symbol|nil] If not `nil`, the method to use to sanitize entries of the array. *Ignored if a block is present.*
    # @param block [Proc] A block to sanitize entries. It must accept the value as unique argument.
    # @return [Array] If the object is an array, then the object itself, a single element array containing the object otherwise.
    def ensure_array(default_value = nil, uniq = false, compact = false, flatten = false, sanitizer = nil, &block)
      rv = is_a?(::Array) ? dup : (default_value || (self.is_a?(NilClass) ? [] : [self]))
      rv = manipulate_array(rv, uniq, compact, flatten).map(&(block || sanitizer)) if block_given? || sanitizer
      manipulate_array(rv, uniq, compact, flatten)
    end

    # Makes sure that the object is an hash. For non hash objects, return an hash basing on the `default_value` parameter.
    #
    # @param access [Symbol|NilClass] The requested access for the keys of the returned object. Can be `:strings`, `:symbols` or `indifferent`.
    #   If `nil` the keys are not modified.
    # @param default_value [Hash|String|Symbol|NilClass] The default value to use. If it is an `Hash`, it is returned as value otherwise it is used to build
    #   as a key to build an hash with the current object as only value (everything but strings and symbols are mapped to `key`).
    #   Passing `nil` is equal to pass an empty Hash.
    # @param sanitizer [Symbol|nil] If not `nil`, the method to use to sanitize values of the hash. *Ignored if `block` is present.*
    # @param block [Proc] A block to sanitize entries. It must accept the value as unique argument.
    # @return [Hash] If the object is an hash, then the object itself, a hash with the object as single value otherwise.
    def ensure_hash(access = nil, default_value = nil, sanitizer = nil, &block)
      default_value = {} if default_value.is_a?(NilClass)

      rv = convert_to_hash(default_value)
      rv = sanitize_hash(rv, sanitizer, block) if block || sanitizer

      rv.respond_to?(:ensure_access) ? rv.ensure_access(access) :rv
    end

    # Converts the object to a boolean.
    #
    # @return [Boolean] The boolean representation of the object.
    def to_boolean
      is_a?(TrueClass) || self == 1.0 || self == 1 || !!(ensure_string =~ ::Lazier::Object::BOOLEAN_TRUE_MATCHER) || false
    end

    # Converts the object to a integer.
    #
    # @param default_value [Fixnum] The value to return if the conversion is not possible.
    # @return [Fixnum] The integer representation of the object.
    def to_integer(default_value = 0)
      to_float(default_value).to_i
    end

    # Converts the object to a float.
    #
    # @param default_value [Float] The value to return if the conversion is not possible.
    # @return [Float] The float representation of the object.
    def to_float(default_value = 0.0)
      is_float? ? ::Kernel.Float(is_a?(::Numeric) ? self : normalize_number) : default_value
    end

    # Returns the rounded float representaton of the object.
    #
    # @param precision [Fixnum] The precision to keep.
    # @return [Float] The rounded float representaton of the object.
    def round_to_precision(precision = 2)
      is_number? ? to_float.round([precision, 0].max) : nil
    end

    # Formats a number.
    # @see Settings#setup_format_number
    #
    # @param precision [Fixnum] The precision to show.
    # @param decimal_separator [String] The string to use as decimal separator.
    # @param add_string [String] The string to append to the number.
    # @param k_separator [String] The string to use as thousands separator.
    # @return [String] The string representation of the object.
    def format_number(precision = nil, decimal_separator = nil, add_string = nil, k_separator = nil)
      if is_number? then
        settings = ::Lazier.settings.format_number
        add_string ||= settings[:add_string]

        rv = ("%0.#{[precision || settings[:precision], 0].max}f" % to_float).split(".")
        rv[0].gsub!(/(\d)(?=(\d{3})+(?!\d))/, "\\1#{k_separator || settings[:k_separator]}")
        rv = rv.join(decimal_separator || settings[:decimal_separator])
        rv += " #{add_string}" if add_string
        rv
      else
        nil
      end
    end

    # Formats a boolean.
    # @see Settings#setup_boolean_names
    #
    # @param true_name [String] The string representation of `true`. Defaults to `Yes`.
    # @param false_name [String] The string representation of `false`. Defaults to `No`.
    # @return [String] The string representation of the object.
    def format_boolean(true_name = nil, false_name = nil)
      settings = ::Lazier.settings.boolean_names
      to_boolean ? (true_name || settings[true]) : (false_name || settings[false])
    end

    # Prepares an object to be printed in list summaries, like `[01/04] Opening this...`.
    #
    # @param length [Fixnum] The minimum length of the label.
    # @param filler [String] The minimum length of the label.
    # @param formatter [Symbol] The method to use to format the label. Must accept the `length` and the `filler arguments.
    # @return [String] The object inspected and formatted.
    def indexize(length = 2, filler = "0", formatter = :rjust)
      self.ensure_string.send(formatter, length, filler)
    end

    # Inspects an object.
    #
    # @param format The format to use.
    # @param as_exception [Boolean] If raise an exception.
    # @return [String] The object inspected and formatted.
    def for_debug(format = :yaml, as_exception = true)
      rv = case format
        when :pretty_json
          ::JSON.pretty_generate(self)
        else
          send("to_#{format}")
      end

      as_exception ? raise(::Lazier::Exceptions::Debug.new(rv)) : rv
    end

    private
      # Performs manipulation on an array.
      #
      # @param rv [Array] The input array.
      # @param uniq [Boolean] If to remove duplicates from the array.
      # @param compact [Boolean] If to compact the array.
      # @param flatten [Boolean] If to flatten the array.
      # @return [Array] The manipulated array.
      def manipulate_array(rv, uniq, compact, flatten)
        rv = rv.flatten if flatten
        rv = rv.uniq if uniq
        rv = rv.compact if compact
        rv
      end

      # Converts the object to a hash.
      #
      # @param default_value [Hash|String|Symbol|NilClass] The default value to use. If it is an `Hash`, it is returned as value otherwise it is used to build
      #   as a key to build an hash with the current object as only value (everything but strings and symbols are mapped to `key`).
      #   Passing `nil` is equal to pass an empty Hash.
      # @return [Hash] An hash.
      def convert_to_hash(default_value)
        if is_a?(::Hash)
          self
        elsif default_value.is_a?(::Hash)
          default_value
        else
          key = default_value.is_a?(::String) || default_value.is_a?(::Symbol) ? default_value : :key
          {key => self}
        end
      end

      # Sanitizes an hash
      #
      # @param hash [Hash] The hash to sanitize.
      # @param sanitizer [Symbol|nil] If not `nil`, the method to use to sanitize values of the hash. *Ignored if `block` is present.*
      # @param block [Proc] A block to sanitize entries. It must accept the value as unique argument.
      # @return [Hash] The sanitized hash.
      def sanitize_hash(hash, sanitizer, block)
        hash.reduce({}) { |h, (k, v)|
          h[k] = block ? block.call(v) : v.send(sanitizer)
          h
        }
      end

  end
end
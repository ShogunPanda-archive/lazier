# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Lazier
  # Extensions for all objects.
  module Object
    include ::ActionView::Helpers::NumberHelper
    extend ::ActiveSupport::Concern

    BOOLEAN_MATCHER = /^(\s*(1|0|true|false|yes|no|t|f|y|n)\s*)$/i
    BOOLEAN_TRUE_MATCHER = /^(\s*(1|true|yes|t|y)\s*)$/i
    INTEGER_MATCHER = /^([+-]?)(\d+)$/
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
      is_a?(::Integer) || is_a?(::TrueClass) || !self || normalize_number =~ ::Lazier::Object::INTEGER_MATCHER
    end

    # Checks if the object is a valid float.
    #
    # @return [Boolean] `true` is a valid float, `false` otherwise.
    def is_float?
      is_a?(::Numeric) || is_a?(::TrueClass) || !self || normalize_number =~ ::Lazier::Object::FLOAT_MATCHER
    end
    alias :is_number? :is_float?

    # Checks if the object is a valid boolean value.
    #
    # @return [Boolean] `true` is a valid boolean value, `false` otherwise.
    def is_boolean?
      is_a?(::TrueClass) || !self || to_s =~ ::Lazier::Object::BOOLEAN_MATCHER
    end

    # Makes sure that the object is set to something meaningful.
    #
    # @params default_value [String] The default value to return if the `verifier` or the block returns true.
    # @params verifier [Symbol] The method used to verify if the object is NOT meaningful. *Ignored if a block is passed.*
    # @return [String] The current object or the `default_value`.
    # TODO@PI: Test me
    def ensure(default_value, verifier = :blank?)
      valid = block_given? ? yield(self) : send(verifier)
      !valid ? self : default_value
    end

    # Makes sure that the object is a string.
    #
    # @params default_value [String] The default value to return if the object is `nil`.
    # @params stringifier [Symbol] The method used to convert the object to a string.
    # @return [String] The string representation of the object.
    # TODO@PI: Verify test - New arguments
    def ensure_string(default_value = "", stringifier = :to_s)
      !nil? ? send(stringifier) : default_value
    end

    # Makes sure that the object is an array. For non array objects, return a single element array containing the object.
    #
    # @params default_value [Array|NilClass] The default array to use. If not specified, an array containing the object is returned.
    # @param uniq [Boolean] If to remove duplicates from the array before sanitizing.
    # @param compact [Boolean] If to compact the array before sanitizing.
    # @param sanitizer [Symbol|nil] If not `nil`, the method to use to sanitize entries of the array. *Ignored if a block is present.*
    # @param block [Proc] A block to sanitize entries. It must accept the value as unique argument.
    # @return [Array] If the object is an array, then the object itself, a single element array containing the object otherwise.
    # TODO@PI: Verify test - New interface
    def ensure_array(default_value = nil, uniq = false, compact = false, sanitizer = nil, &block)
      rv = is_a?(::Array) ? self : (default_value || [self])
      rv.collect!(&(block || sanitizer))
      rv.uniq! if uniq
      rv.compact! if compact
      rv
    end

    # Makes sure that the object is an hash. For non hash objects, return an hash basing on the `default_value` parameter.
    #
    # @params default_value [Hash|Object|NilClass] The default value to use. If it is an `Hash`, it is returned as value otherwise it is used to build as a key to build an hash with the current object as only value (everything but strings and symbols are mapped to `key`).
    # @param sanitizer [Symbol|nil] If not `nil`, the method to use to sanitize values of the hash. *Ignored if a block is present.*
    # @return [Hash] If the object is an hash, then the object itself, a hash with the object as single value otherwise.
    # TODO@PI: Test me
    def ensure_hash(default_value = nil, sanitizer = nil, &block)
      rv = if is_a?(::Hash) then
        self
      elsif default_value.is_a?(::Hash) then
        default_value
      else
        key = :key if !default_value.is_a?(::String) && !default_value.is_a?(::Symbol)
        {key => self}
      end

      if block_given? || sanitizer then
        rv.inject({}) {|h, (k, v)|
          h[k] = block_given? ? yield(v) : v.send(sanitizer)
        }
      else
        rv
      end
    end

    # Converts the object to a boolean.
    #
    # @return [Boolean] The boolean representation of the object.
    def to_boolean
      is_a?(TrueClass) || self == 1.0 || self == 1 || ensure_string =~ ::Lazier::Object::BOOLEAN_TRUE_MATCHER
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
      is_number? ? number_with_precision(to_float, precision: [precision, 0].max) : nil
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
        format, unit = (add_string  ? ["%n %u", add_string] : ["%n", ""])

        number_to_currency(self, {precision: [precision || settings[:precision], 0].max, separator: decimal_separator || settings[:decimal_separator], delimiter: k_separator || settings[:k_separator], format: format, unit: unit})
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
    # TODO@PI: Test me
    def indexize(length = 2, filler = "0", formatter = :rjust)
      self.ensure_string.send(formatter, length, filler)
    end

    # Inspects an object.
    #
    # @param format The format to use.
    # @param as_exception [Boolean] If raise an exception.
    # @return [String] The object inspected and formatted.
    def analyze(format = :yaml, as_exception = true)
      rv = case format
        when :pretty_json
          ::JSON.pretty_generate(self)
        else
          send("to_#{format}")
      end

      as_exception ? raise(::Lazier::Exceptions::Debug.new(rv)) : rv
    end
  end
end
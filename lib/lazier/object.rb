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

    BOOLEAN_MATCHER = /^(.*(1|0|true|false|yes|no|t|f|y|n).*)$/i
    BOOLEAN_TRUE_MATCHER = /^(.*(1|true|yes|t|y).*)$/i
    INTEGER_MATCHER = /^([+-]?)(\d+)$/
    FLOAT_MATCHER = /^([+-]?)(\d+)([.,]\d+)?$/

    # Normalizes a number for conversion. Basically this methods removes all separator and ensures that `.` is used for decimal separator.
    #
    # @return [String] The normalized number.
    # TODO@PI: Verify test
    def normalize_number
      is_boolean? ? to_i : ensure_string.strip.gsub(/[\.,](?=(.*[\.,]))/, "").gsub(",", ".")
    end

    # Checks if the object is a valid integer.
    #
    # @return [Boolean] `true` is a valid integer, `false` otherwise.
    # TODO@PI: Verify test
    def is_integer?
      is_a?(::Integer) || normalize_number =~ ::Lazier::Object::INTEGER_MATCHER
    end

    # Checks if the object is a valid float.
    #
    # @return [Boolean] `true` is a valid float, `false` otherwise.
    # TODO@PI: Verify test
    def is_float?
      is_a?(::Numeric) || normalize_number =~ ::Lazier::Object::FLOAT_MATCHER
    end
    alias :is_number? :is_float?

    # Checks if the object is a valid boolean value.
    #
    # @return [Boolean] `true` is a valid boolean value, `false` otherwise.
    # TODO@PI: Verify test
    def is_boolean?
      is_a?(::TrueClass) || !self || to_s =~ ::Lazier::Object::BOOLEAN_MATCHER
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
    # @return [Array] If the object is an array, then the object itself, a single element array containing the object otherwise.
    # TODO@PI: Verify test - Default value
    def ensure_array(default_value = nil)
      is_a?(::Array) ? self : (default_value || [self])
    end

    # TODO@PI: #ensure_hash

    # Converts the object to a boolean.
    #
    # @return [Boolean] The boolean representation of the object.
    # TODO@PI: Verify test
    def to_boolean
      is_a?(TrueClass) || self == 1.0 || ensure_string =~ ::Lazier::Object::BOOLEAN_TRUE_MATCHER
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
    # TODO@PI: Verify test
    def to_float(default_value = 0.0)
      is_float? ? ::Kernel.Float(is_a?(::Numeric) ? self : normalize_number) : default_value
    end

    # Returns the rounded float representaton of the object.
    #
    # @param precision [Fixnum] The precision to keep.
    # @return [Float] The rounded float representaton of the object.
    # TODO@PI: Verify test
    def round_to_precision(precision = 2)
      is_number? ? number_with_precision(self, precision: precision) : nil
    end

    # Formats a number.
    # @see Settings#setup_format_number
    #
    # @param precision [Fixnum] The precision to show.
    # @param decimal_separator [String] The string to use as decimal separator.
    # @param add_string [String] The string to append to the number.
    # @param k_separator [String] The string to use as thousands separator.
    # @return [String] The string representation of the object.
    # TODO@PI: Verify test
    def format_number(precision = nil, decimal_separator = nil, add_string = nil, k_separator = nil)
      settings = ::Lazier.settings.format_number
      add_string ||= settings[:add_string]
      format, unit = (add_string  ? ["%n %u", add_string] : ["%n", ""])

      number_to_currency(self, {precision: precision || settings[:precision], separator: decimal_separator || settings[:decimal_separator], delimiter: k_separator || settings[k_separator], format: format, unit: unit})
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

    # Inspects an object.
    #
    # @param format The format to use.
    # @param as_exception [Boolean] If raise an exception.
    # @return [String] The object inspected and formatted.
    def analyze(format = :yaml, as_exception = true)
      rv = case :format
        when :pretty_json
          ::JSON.pretty_generate(self)
        else
          send("to_#{format}")
      end

      as_exception ? raise(::Lazier::Exceptions::Debug.new(rv)) : rv
    end
  end
end
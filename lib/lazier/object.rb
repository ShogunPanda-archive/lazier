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

    # Normalizes a number for conversion. Basically this methods removes all separator and ensures that `.` is used for decimal separator.
    #
    # @return [String] The normalized number.
    def normalize_number
      rv = ""

      if self == true then
        rv = "1"
      elsif !self then
        rv = "0"
      else
        rv = self.ensure_string.strip
        rv = rv.split(/[\.,]/)
        rv[-1] = "." + rv[-1] if rv.length > 1
        rv = rv.join("")
      end

      rv
    end

    # Checks if the object is a valid number.
    #
    # @return [Boolean] `true` is a valid number, `false` otherwise.
    def is_number?
      self.is_float?
    end

    # Checks if the object is a valid integer.
    #
    # @return [Boolean] `true` is a valid integer, `false` otherwise.
    def is_integer?
      self.is_a?(::Integer) || /^([+-]?)(\d+)$/.match(self.normalize_number)
    end

    # Checks if the object is a valid float.
    #
    # @return [Boolean] `true` is a valid float, `false` otherwise.
    def is_float?
      self.is_a?(::Float) || /^([+-]?)(\d+)([.,]\d+)?$/.match(self.normalize_number)
    end

    # Checks if the object is a valid boolean value.
    #
    # @return [Boolean] `true` is a valid boolean value, `false` otherwise.
    def is_boolean?
      self.is_a?(::TrueClass) || self.is_a?(::FalseClass) || self.is_a?(::NilClass) || (self.ensure_string.strip =~ /^(1|0|true|false|yes|no|t|f|y|n)$/i)
    end

    # Makes sure that the object is an array. For non array objects, return a single element array containing the object.
    #
    # @return [Array] If the object is an array, then the object itself, a single element array containing the object otherwise.
    def ensure_array
      self.is_a?(::Array) ? self : [self]
    end

    # Makes sure that the object is a string. For `nil`, it returns "".
    #
    # @return [String] The string representation of the object.
    def ensure_string
      if self.is_a?(::String) then
        self
      else
        self.present? ? self.to_s : ""
      end
    end

    # Converts the object to a float.
    #
    # @param default_value [Float] The value to return if the conversion is not possible.
    # @return [Float] The float representation of the object.
    def to_float(default_value = 0.0)
      if self.is_a?(::Float)
        self
      elsif self.is_a?(::Integer)
        self.to_f
      else
        self.is_float? ? ::Kernel.Float(self.normalize_number) : default_value
      end
    end

    # Converts the object to a integer.
    #
    # @param default_value [Fixnum] The value to return if the conversion is not possible.
    # @return [Fixnum] The integer representation of the object.
    def to_integer(default_value = 0)
      if self.is_a?(::Integer)
        self
      elsif self.is_a?(::Float)
        self.to_i
      else
        self.is_integer? ? ::Kernel.Integer(self.normalize_number) : default_value
      end
    end

    # Converts the object to a boolean.
    #
    # @return [Boolean] The boolean representation of the object.
    def to_boolean
      rv = self
      rv = rv.to_i if rv.is_a?(::Float)
      (rv.is_a?(TrueClass) || /^(1|on|true|yes|t|y)$/i.match(rv.ensure_string.strip)) ? true : false
    end

    # Returns the rounded float representaton of the object.
    #
    # @param prec [Fixnum] The precision to keep.
    # @return [Float] The rounded float representaton of the object.
    def round_to_precision(prec = 2)
      (self.is_number? && prec >= 0) ? number_with_precision(self, precision: prec) : nil
    end

    # Formats a number.
    # @see Settings#setup_format_number
    #
    # @param prec [Fixnum] The precision to show.
    # @param decimal_separator [String] The string to use as decimal separator.
    # @param add_string [String] The string to append to the number.
    # @param k_separator [String] The string to use as thousands separator.
    # @return [String] The string representation of the object.
    def format_number(prec = nil, decimal_separator = nil, add_string = nil, k_separator = nil)
      prec = ::Lazier.settings.format_number[:prec] if prec.nil?
      decimal_separator = ::Lazier.settings.format_number[:decimal_separator] if decimal_separator.nil?
      add_string = ::Lazier.settings.format_number[:add_string] if add_string.nil?
      k_separator = ::Lazier.settings.format_number[:k_separator] if k_separator.nil?

      (self.is_number? && prec >= 0) ? number_to_currency(self, {precision: prec, separator: decimal_separator, delimiter: k_separator, format: (add_string.blank? ? "%n" : "%n %u"), unit: (add_string.blank? ? "" : add_string.strip)}) : nil
    end

    # Formats a boolean.
    # @see Settings#setup_boolean_names
    #
    # @param true_name [String] The string representation of `true`. Defaults to `Yes`.
    # @param false_name [String] The string representation of `false`. Defaults to `No`.
    # @return [String] The string representation of the object.
    def format_boolean(true_name = nil, false_name = nil)
      names = {
        true => true_name || ::Lazier.settings.boolean_names[true],
        false => false_name || ::Lazier.settings.boolean_names[false]
      }

      names[self.to_boolean]
    end

    # Inspects an object.
    #
    # @param format The format to use.
    # @param must_raise [Boolean] If raise a Dump exception.
    # @return [String] The object inspected and formatted.
    def debug_dump(format = :yaml, must_raise = true)
      rv = ""

      begin
        if format == :pretty_json then
          rv = ::JSON.pretty_generate(self)
        else
          rv = self.send("to_#{format}")
        end
      rescue
        rv = self.inspect
      end

      must_raise ? raise(::Lazier::Exceptions::Dump.new(rv)) : rv
    end
  end
end
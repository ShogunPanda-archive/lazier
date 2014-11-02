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
      boolean? ? to_i.to_s : ensure_string.strip.gsub(/[\.,](?=(.*[\.,]))/, "").gsub(",", ".")
    end

    # Checks if the object is of a numeric class of matches a numeric string expression.
    #
    # @return [Boolean] `true` is a valid numeric object, `false` otherwise.
    def number?(klass = Integer, matcher = ::Lazier::Object::FLOAT_MATCHER)
      nil? || is_a?(klass) || boolean? || normalize_number =~ matcher
    end

    # Checks if the object is a valid integer.
    #
    # @return [Boolean] `true` is a valid integer, `false` otherwise.
    def integer?
      number?(Integer, ::Lazier::Object::INTEGER_MATCHER)
    end

    # Checks if the object is a valid float.
    #
    # @return [Boolean] `true` is a valid float, `false` otherwise.
    def float?
      number?(Numeric, ::Lazier::Object::FLOAT_MATCHER)
    end

    # Checks if the object is a valid boolean value.
    #
    # @return [Boolean] `true` is a valid boolean value, `false` otherwise.
    def boolean?
      nil? || is_a?(::TrueClass) || is_a?(::FalseClass) || to_s =~ ::Lazier::Object::BOOLEAN_MATCHER
    end

    # Sends a method to the object. If the objects doesn't not respond to the method, it returns `nil` instead of raising an exception.
    #
    # @param method [Symbol] The method to send.
    # @param args [Array] The arguments to send.
    # @param block [Proc] The block to pass to the method.
    # @return [Object|nil] The return value of the method or `nil`, if the object does not respond to the method.
    def safe_send(method, *args, &block)
      send(method, *args, &block)
    rescue NoMethodError
      nil
    end

    # Makes sure that the object is set to something meaningful.
    #
    # @param default [String] The default value to return if the `verifier` or the block returns true.
    # @param verifier [Symbol] The method used to verify if the object is NOT meaningful. *Ignored if a block is passed.*
    # @return [String] The current object or the `default_value`.
    def ensure(default, verifier = :blank?)
      valid = block_given? ? yield(self) : send(verifier)
      !valid ? self : default
    end

    # Makes sure that the object is a string.
    #
    # @param default [String] The default value to return if the object is `nil`. It is also passed to the block stringifier.
    # @param conversion_method [Symbol] The method used to convert the object to a string. *Ignored if a block is passed.*
    # @return [String] The string representation of the object.
    def ensure_string(default = "", conversion_method = :to_s)
      if is_a?(NilClass)
        default
      else
        block_given? ? yield(self, default) : send(conversion_method)
      end
    end

    # Makes sure that the object is an array. For non array objects, return a single element array containing the object.
    #
    # @param default [Array|NilClass] The default array to use. If not specified, an array containing the object is returned.
    # @param no_duplicates [Boolean] If to remove duplicates from the array before sanitizing.
    # @param compact [Boolean] If to compact the array before sanitizing.
    # @param flatten [Boolean] If to flatten the array before sanitizing.
    # @param sanitizer [Symbol|NilClass] If not `nil`, the method to use to sanitize entries of the array. *Ignored if a block is present.*
    # @param block [Proc] A block to sanitize entries. It must accept the value as unique argument.
    # @return [Array] If the object is an array, then the object itself, a single element array containing the object otherwise.
    def ensure_array(default: nil, no_duplicates: false, compact: false, flatten: false, sanitizer: nil, &block)
      rv =
        if is_a?(::Array)
          self
        else
          default || [self].compact
        end

      rv = manipulate_array(rv, no_duplicates, compact, flatten).map(&(block || sanitizer)) if block_given? || sanitizer
      manipulate_array(rv, no_duplicates, compact, flatten)
    end

    # Makes sure that the object is an hash. For non hash objects, return an hash basing on the `default_value` parameter.
    #
    # @see Lazier::Hash#ensure_access
    #
    # @param accesses [Symbol|NilClass|Array] The requested access for the keys of the returned object.
    # @param default [Hash|String|Symbol|NilClass] The default value to use. If it is an `Hash`, it is returned as value otherwise it is used to build
    #   as a key to build an hash with the current object as only value (everything but strings and symbols are mapped to `key`).
    #   Passing `nil` is equal to pass an empty Hash.
    # @param sanitizer [Symbol|NilClass] If not `nil`, the method to use to sanitize values of the hash. *Ignored if `block` is present.*
    # @param block [Proc] A block to sanitize entries. It must accept the value as unique argument.
    # @return [Hash] If the object is an hash, then the object itself, a hash with the object as single value otherwise.
    def ensure_hash(accesses: nil, default: {}, sanitizer: nil, &block)
      rv = convert_to_hash(default)
      rv = sanitize_hash(rv, sanitizer, block) if block || sanitizer

      rv.respond_to?(:ensure_access) ? rv.ensure_access(accesses.ensure_array) : rv
    end

    # Converts the object to a boolean.
    #
    # @return [Boolean] The boolean representation of the object.
    def to_boolean
      is_a?(TrueClass) || to_integer == 1 || ::Lazier::Object::BOOLEAN_TRUE_MATCHER.match(ensure_string).is_a?(MatchData)
    end

    # Converts the object to a integer.
    #
    # @param default [Fixnum] The value to return if the conversion is not possible.
    # @return [Fixnum] The integer representation of the object.
    def to_integer(default = 0)
      to_float(default).to_i
    end

    # Converts the object to a float.
    #
    # @param default [Float] The value to return if the conversion is not possible.
    # @return [Float] The float representation of the object.
    def to_float(default = 0.0)
      if float?
        ::Kernel.Float(is_a?(::Numeric) ? self : normalize_number)
      else
        default
      end
    end

    # Converts an object to a pretty formatted JSON string.
    #
    # @return [String] The object as a pretty JSON string.
    def to_pretty_json
      Lazier.platform != :java ? Oj.dump(self, mode: :compat, indent: 2) : ::JSON.pretty_generate(self)
    end

    # Inspects an object.
    #
    # @param format The format to use. If different from `:pretty_json`, the object must respond to the `to_#{format}` method.
    # @param as_exception [Boolean] If raise an exception.
    # @return [String] The object inspected and formatted.
    def to_debug(format: :pretty_json, as_exception: true)
      rv = send("to_#{format}")
      as_exception ? raise(::Lazier::Exceptions::Debug, rv) : rv
    end

    # Returns the rounded float representaton of the object.
    #
    # @param precision [Fixnum] The precision to keep.
    # @return [Float] The rounded float representaton of the object.
    def round_to_precision(precision = 2)
      number? ? to_float.round([precision, 0].max) : nil
    end

    # Formats a number.
    # @see Settings#setup_format_number
    #
    # @param precision [Fixnum|NilClass] The precision to show.
    # @param decimal_separator [String|NilClass] The string to use as decimal separator.
    # @param add_string [String|NilClass] The string to append to the number.
    # @param k_separator [String|NilClass] The string to use as thousands separator.
    # @return [String|NilClass] The string representation of the object or `nil`, if the object is not a number.
    def format_number(precision: nil, decimal_separator: nil, add_string: nil, k_separator: nil)
      if number?
        settings = ::Lazier.settings.format_number
        add_string ||= settings[:add_string]

        rv = format("%0.#{[precision || settings[:precision], 0].max}f", to_float).split(".")
        rv[0].gsub!(/(\d)(?=(\d{3})+(?!\d))/, "\\1#{k_separator || settings[:k_separator]}")
        rv = rv.join(decimal_separator || settings[:decimal_separator])
        add_string ? rv + " #{add_string}" : rv
      else
        nil
      end
    end

    # Formats a boolean.
    # @see Settings#setup_boolean_names
    #
    # @param true_name [String|NilClass] The string representation of `true`. Defaults to `Yes`.
    # @param false_name [String|NilClass] The string representation of `false`. Defaults to `No`.
    # @return [String] The string representation of the object.
    def format_boolean(true_name: nil, false_name: nil)
      settings = ::Lazier.settings.boolean_names
      to_boolean ? (true_name || settings[true]) : (false_name || settings[false])
    end

    # Prepares an object to be printed in list summaries, like `[01/04] Opening this...`.
    #
    # @param length [Fixnum] The minimum length of the label.
    # @param filler [String] The minimum length of the label.
    # @param formatter [Symbol] The method to use to format the label. Must accept the `length` and the `filler arguments.
    # @return [String] The object inspected and formatted.
    def indexize(length: 2, filler: "0", formatter: :rjust)
      ensure_string.send(formatter, length, filler)
    end

    private

    # :nodoc:
    def manipulate_array(rv, no_duplicates, compact, flatten)
      rv = rv.flatten if flatten
      rv = rv.uniq if no_duplicates
      rv = rv.compact if compact
      rv
    end

    # :nodoc:
    def convert_to_hash(value)
      if self.is_a?(::Hash)
        self
      elsif value.is_a?(::Hash)
        value
      else
        key = value.is_a?(::String) || value.is_a?(::Symbol) ? value : :key
        {key => self}
      end
    end

    # :nodoc:
    def sanitize_hash(hash, sanitizer, block)
      operator = block ? block : ->(v) { v.send(sanitizer) }

      hash.reduce(hash.class.new) { |h, (k, v)|
        h[k] = operator.call(v)
        h
      }
    end
  end
end

#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Lazier
  # Settings for the extensions.
  #
  # @attribute [r] format_number
  #   @return [Hash] Settings for numbers formatting.
  # @attribute [r] boolean_names
  #   @return [Hash] String representations of booleans.
  # @attribute [r] date_names
  #   @return [Hash] String representations of days and months.
  # @attribute [r] date_formats
  #   @return [Hash] Custom date and time formats.
  # @attribute [r] i18n
  #   @return [R18n::Translation] The translation object.
  class Settings
    attr_reader :format_number, :boolean_names, :date_names, :date_formats, :i18n

    # Returns the singleton instance of the settings.
    #
    # @param force [Boolean] If to force recreation of the instance.
    # @return [Settings] The singleton instance of the settings.
    def self.instance(force = false)
      @instance = nil if force
      @instance ||= new
    end

    # Initializes a new settings object.
    def initialize
      Lazier.load_datetime
      @i18n = Lazier::I18n.instance
      setup
    end

    # Setups the current instance.
    def setup
      setup_format_number
      setup_boolean_names
      setup_date_formats
      setup_date_names
    end

    # Setups formatters for a number.
    # @see Object#format_number
    #
    # @param precision [Fixnum] The precision to show.
    # @param decimal_separator [String] The string to use as decimal separator.
    # @param add_string [String] The string to append to the number.
    # @param k_separator [String] The string to use as thousands separator.
    # @return [Hash] The new formatters.
    def setup_format_number(precision: 2, decimal_separator: ".", add_string: nil, k_separator: ",")
      @format_number = ::HashWithIndifferentAccess.new(
        precision: precision, decimal_separator: decimal_separator, add_string: add_string, k_separator: k_separator
      )
    end

    # Setups strings representation of booleans.
    # @see Object#format_boolean
    #
    # @param true_name [String] The string representation of `true`. Defaults to `Yes`.
    # @param false_name [String] The string representation of `false`. Defaults to `No`.
    # @return [Hash] The new representations.
    def setup_boolean_names(true_name: nil, false_name: nil)
      names = i18n.translate("boolean")
      @boolean_names = {true => true_name || names[0], false => false_name || names[1]}
    end

    # Setups custom formats for dates and times.
    # @see DateTime#lstrftime
    #
    # @param formats [Hash] The format to add or replace.
    # @param replace [Boolean] If to discard current formats.
    # @return [Hash] The new formats.
    def setup_date_formats(formats = nil, replace = false)
      @date_formats = HashWithIndifferentAccess.new if replace || !@date_formats

      formats = {ct_date: "%Y-%m-%d", ct_time: "%H:%M:%S", ct_date_time: "%F %T", ct_iso_8601: "%FT%T%z" } unless formats.is_a?(::Hash)
      @date_formats.merge!(formats)
      ::Time::DATE_FORMATS.merge!(@date_formats)

      @date_formats
    end

    # Setups strings representation of days and months.
    # @see DateTime::ClassMethods#days
    # @see DateTime::ClassMethods#months
    # @see DateTime#lstrftime
    #
    # @param long_months [Array] The string representation of months.
    # @param short_months [Array] The abbreviated string representation of months.
    # @param long_days [Array] The string representation of days.
    # @param short_days [Array] The abbreviated string representation of days.
    # @return [Hash] The new representations.
    def setup_date_names(long_months: nil, short_months: nil, long_days: nil, short_days: nil)
      definitions = prepare_definitions

      @date_names = {
        long_months: long_months.ensure(definitions.long_months),
        short_months: short_months.ensure(definitions.short_months),
        long_days: long_days.ensure(definitions.long_days),
        short_days: short_days.ensure(definitions.short_days)
      }

      @date_names.extend(Lazier::Hash)
      @date_names = @date_names.ensure_access(:dotted, :indifferent)
    end

    private

    # :nodoc:
    def prepare_definitions
      definitions = i18n.translate("date")
      definitions.extend(Lazier::Hash)
      definitions.ensure_access(:dotted)
    end
  end
end

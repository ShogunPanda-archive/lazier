# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Lazier
  # Settings for the extensions.
  #
  # @attr [Hash] format_number Settings for numbers formatting.
  # @attr [Hash] boolean_names String representations of booleans.
  # @attr [Hash] date_names String representations of days and months.
  # @attr [Hash] date_formats Custom date and time formats.
  class Settings
    attr_reader :format_number
    attr_reader :boolean_names
    attr_reader :date_names
    attr_reader :date_formats

    # Returns the singleton instance of the settings.
    #
    # @param force [Boolean] If to force recreation of the instance.
    # @return [Settings] The singleton instance of the settings.
    def self.instance(force = false)
      @instance = nil if force
      @instance ||= self.new
    end

    # Initializes a new settings object.
    def initialize
      self.setup_format_number
      self.setup_boolean_names
      self.setup_date_formats
      self.setup_date_names
    end

    # Setups formatters for a number.
    # @see Object#format_number
    #
    # @param prec [Fixnum] The precision to show.
    # @param decimal_separator [String] The string to use as decimal separator.
    # @param add_string [String] The string to append to the number.
    # @param k_separator [String] The string to use as thousands separator.
    # @return [Hash] The new formatters.
    def setup_format_number(prec = 2, decimal_separator = ".", add_string = "", k_separator = ",")
      @format_number = { prec: prec, decimal_separator: decimal_separator, add_string: add_string, k_separator: k_separator}
    end

    # Setups strings representation of booleans.
    # @see Object#format_boolean
    #
    # @param true_name [String] The string representation of `true`. Defaults to `Yes`.
    # @param false_name [String] The string representation of `false`. Defaults to `No`.
    # @return [Hash] The new representations.
    def setup_boolean_names(true_name = nil, false_name = nil)
      true_name ||= Lazier.i18n.boolean[0]
      false_name ||= Lazier.i18n.boolean[1]
      @boolean_names = {true => true_name, false => false_name}
    end

    # Setups custom formats for dates and times.
    # @see DateTime#lstrftime
    #
    # @param formats [Hash] The format to add or replace.
    # @param replace [Boolean] If to discard current formats.
    # @return [Hash] The new formats.
    def setup_date_formats(formats = nil, replace = false)
      formats = {ct_date: "%Y-%m-%d", ct_time: "%H:%M:%S", ct_date_time: "%F %T", ct_iso_8601: "%FT%T%z" } if formats.blank?

      if formats.is_a?(::Hash) then
        if !replace then
          @date_formats ||= {}
          @date_formats.merge!(formats)
        else
          @date_formats = formats
        end

        @date_formats.each_pair do |k, v| ::Time::DATE_FORMATS[k] = v end
      end

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
    def setup_date_names(long_months = nil, short_months = nil, long_days = nil, short_days = nil)
      long_months = Lazier.i18n.date.long_months if long_months.blank?
      short_months = Lazier.i18n.date.short_months if short_months.blank?
      long_days = Lazier.i18n.date.long_days if long_days.blank?
      short_days = Lazier.i18n.date.short_days if short_days.blank?

      @date_names = { long_months: long_months, short_months: short_months, long_days: long_days, short_days: short_days }
    end
  end
end

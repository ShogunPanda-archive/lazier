# encoding: utf-8
#
# This file is part of the cowtech-extensions gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Cowtech
	module Extensions
    # Settings for the extensions.
    class Settings
      # Settings for numbers formatting.
      attr_reader :format_number

      # String representations of booleans.
      attr_reader :boolean_names

      # String representations of days and months.
      attr_reader :date_names

      # Custom date and time formats.
      attr_reader :date_formats

      # Returns the singleton instance of the settings.
      #
      # @return [Settings] The singleton instance of the settings.
      def self.instance
        @instance ||= Cowtech::Extensions::Settings.new
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
        @format_number = {
          :prec => prec,
          :decimal_separator => decimal_separator,
          :add_string => add_string,
          :k_separator => k_separator
        }
      end

      # Setups strings representation of booleans.
      # @see Object#format_boolean
      #
      # @param true_name [String] The string representation of `true`. Defaults to `Yes`.
      # @param false_name [String] The string representation of `false`. Defaults to `No`.
      # @return [Hash] The new representations.
      def setup_boolean_names(true_name = nil, false_name = nil)
        true_name ||= "Yes"
        false_name ||= "No"
        @boolean_names = {true => true_name, false => false_name}
      end

      # Setups custom formats for dates and times.
      # @see DateTime#lstrftime
      #
      # @param formats [Hash] The format to add or replace.
      # @param replace [Boolean] If to discard current formats.
      # @return [Hash] The new formats.
      def setup_date_formats(formats = nil, replace = false)
        formats = {
            :ct_date => "%Y-%m-%d",
            :ct_time => "%H:%M:%S",
            :ct_date_time => "%F %T",
            :ct_iso_8601 => "%FT%T%z"
        } if formats.blank?

        if formats.is_a?(Hash) then
          if !replace then
            @date_formats ||= {}
            @date_formats.merge!(formats)
          else
            @date_formats = formats
          end

          @date_formats.each_pair do |k, v| Time::DATE_FORMATS[k] = v end
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
        long_months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"] if long_months.blank?
        short_months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"] if short_months.blank?
        long_days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]  if long_days.blank?
        short_days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]  if short_days.blank?

        @date_names = {
          :long_months => long_months,
          :short_months => short_months,
          :long_days => long_days,
          :short_days => short_days
        }
      end
    end
	end
end

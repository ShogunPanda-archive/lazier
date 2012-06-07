# encoding: utf-8
#
# This file is part of the cowtech-extensions gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Cowtech
	module Extensions
    class Settings
      attr_reader :format_number, :boolean_names, :date_names, :date_formats

      def self.instance
        @@instance ||= Cowtech::Extensions::Settings.new
      end

      def initialize
        self.setup_format_number
        self.setup_boolean_names
        self.setup_date_formats
        self.setup_date_names
      end

      def setup_format_number(prec = 2, decimal_separator = ".", add_string = "", k_separator = ",")
        @format_number = {
          :prec => prec,
          :decimal_separator => decimal_separator,
          :add_string => add_string,
          :k_separator => k_separator
        }
      end

      def setup_boolean_names(true_name = "Yes", false_name = "No")
        @boolean_names = {true => true_name, false => false_name}
      end

      def setup_date_formats(formats = nil, replace = false)
        formats = {
            :ct_date => "%Y-%m-%d",
            :ct_time => "%H:%M:%S",
            :ct_date_time => "%F %T",
            :ct_iso_8601 => "%FT%T%z"
        } if formats.blank?

        if !replace then
          @date_formats ||= {}
          @date_formats.merge!(formats)
        else
          @date_formats = formats
        end

        @date_formats.each_pair do |k, v| Time::DATE_FORMATS[k] = v end
      end

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

		module Exceptions
			class Dump < ::RuntimeError
			end
		end
	end
end

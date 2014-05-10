# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Lazier
  # Extensions for date and time objects.
  module DateTime
    extend ::ActiveSupport::Concern

    # General methods.
    module ClassMethods
      # Returns strings representations of days.
      # @see Settings#setup_date_names
      #
      # @param short [Boolean] If return the abbreviated representations.
      # @return [Array] Return string representations of days.
      def days(short = true)
        ::Lazier.settings.date_names[short ? :short_days : :long_days].map.with_index {|label, index|
          {value: (index + 1).to_s, label: label}
        }
      end

      # Returns strings representations of months.
      # @see Settings#setup_date_names
      #
      # @param short [Boolean] If return the abbreviated representations.
      # @return [Array] Return string representations of months.
      def months(short = true)
        ::Lazier.settings.date_names[short ? :short_months : :long_months].map.with_index {|label, index|
          {value: (index + 1).to_s.rjust(2, "0"), label: label}
        }
      end

      # Returns a range of years.
      #
      # ```ruby
      # Date.years(3, false, 2010)
      # # => [2007, 2008, 2009, 2010]
      # ```
      #
      # ```ruby
      # Date.years(1, true, 2010, true)
      # # => [{:value=>2009, :label=>2009}, {:value=>2010, :label=>2010}, {:value=>2011, :label=>2011}]
      # ```
      #
      #
      # @param offset [Fixnum] The width of the range.
      # @param also_future [Boolean] If return also future years.
      # @param reference [Fixnum] The ending (or middle, if `also_future` is `true`) value of the range. Defaults to the current year.
      # @param as_objects [Boolean] If to return years in hashes with `:value` and `label` keys.
      # @return [Array] A range of years. Every entry is
      def years(offset = 10, also_future = true, reference = nil, as_objects = false)
        y = reference || ::Date.today.year
        (y - offset..(also_future ? y + offset : y)).map { |year| as_objects ? {value: year, label: year} : year }
      end

      # Returns all the availabe timezones.
      #
      # @return [Array]All the zone available.
      def timezones
        ::ActiveSupport::TimeZone.all
      end

      # Returns a list of names of all timezones.
      #
      # @param with_dst [Boolean] If include DST version of the zones.
      # @param dst_label [String] Label for the DST indication. Defaults to `(DST)`.
      # @return [Array] A list of names of timezones.
      def list_timezones(with_dst = true, dst_label = nil)
        ::ActiveSupport::TimeZone.list_all(with_dst, dst_label)
      end

      # Find a zone by its name.
      #
      # @param name [String] The zone name.
      # @param dst_label [String] Label for the DST indication. Defaults to `(DST)`.
      # @return [TimeZone] A timezone or `nil` if no zone was found.
      def find_timezone(name = true, dst_label = nil)
        ::ActiveSupport::TimeZone.find(name, dst_label)
      end

      # Returns a string representation of a timezone.
      #
      # ```ruby
      # DateTime.parameterize_zone(ActiveSupport::TimeZone["Pacific Time (US & Canada)"])
      # # => "-0800@pacific-time-us-canada"
      # ```
      # @param tz [TimeZone] The zone to represent.
      # @param with_offset [Boolean] If to include offset into the representation.
      # @return [String] A string representation which can be used for searches.
      def parameterize_zone(tz, with_offset = true)
        ::ActiveSupport::TimeZone.parameterize_zone(tz, with_offset)
      end

      # Finds a parameterized timezone.
      # @see DateTime#parameterize_zone
      #
      # @param tz [String] The zone to unparameterize.
      # @param as_string [Boolean] If return just the zone name.
      # @param dst_label [String] Label for the DST indication. Defaults to `(DST)`.
      # @return [String|TimeZone] The found timezone or `nil` if the zone is not valid.
      def unparameterize_zone(tz, as_string = false, dst_label = nil)
        ::ActiveSupport::TimeZone.unparameterize_zone(tz, as_string, dst_label)
      end

      # Returns an offset in rational value.
      #
      # @param offset [Fixnum] The offset to convert.
      # @return [Rational] The converted offset.
      def rationalize_offset(offset)
        ::ActiveSupport::TimeZone.rationalize_offset(offset)
      end

      # Returns the Easter (according to Gregorian calendar) date for the year.
      # @see http://en.wikipedia.org/wiki/Computus#Anonymous_Gregorian_algorithm
      #
      # @param year [Fixnum] The year to compute the date for. Defaults to the current year.
      # @return [Date] The Easter date for the year.
      def easter(year = nil)
        year = ::Date.today.year unless year.is_integer?

        # Compute using Anonymous Gregorian Algorithm: http://en.wikipedia.org/wiki/Computus#Anonymous_Gregorian_algorithm
        data = easter_start(year)
        data = easter_divide(data)
        data = easter_aggregate(year, data)
        data = easter_prepare(year, data)
        day, month = easter_end(data)

        ::Date.civil(year, month, day)
      end

      # Lookups a custom datetime format.
      # @see Settings#setup_date_formats
      #
      # @param key [Symbol] The name of the format to search.
      # @return [String] The format or the name itself (if the format has not been found).
      def custom_format(key)
        ::Lazier.settings.date_formats.fetch(key, key)
      end

      # Checks if the date is valid against to a specific format.
      # @see DateTime#custom_format
      #
      # @param value [String] The value to check.
      # @param format [String] The format to check the value against.
      # @return [Boolean] `true` if the value is valid against the format, `false` otherwise.
      def valid?(value, format = "%F %T")
        ::DateTime.strptime(value, custom_format(format))
        true
      rescue
        false
      end
      alias_method :is_valid?, :valid?

      private

      # Part one of Easter calculation.
      #
      # @param year [Fixnum] The year to compute the date for.
      # @return [Array] Partial variables for #easter_divide.
      def easter_start(year)
        [year % 19, (year / 100.0).floor, year % 100]
      end

      # Part two of Easter calculation.
      # @param data [Fixnum] Partial variables from #easter_start.
      # @return [Array] Partial variables for #easter_aggregate.
      def easter_divide(data)
        _, b, c = data

        [
          b - (b / 4.0).floor - ((b - ((b + 8) / 25.0).floor + 1) / 3.0).floor,
          b % 4,
          (c / 4.0).floor,
          c % 4
        ]
      end

      # Part three of Easter calculation.
      #
      # @param data [Fixnum] Partial variables from #easter_divide.
      # @return [Array] Partial variables for #easter_prepare.
      def easter_aggregate(year, data)
        a = year % 19
        x, e, i, k = data
        h = ((19 * a) + x + 15) % 30
        [h, (32 + (2 * e) + (2 * i) - h - k) % 7]
      end

      # Part four of Easter calculation
      # @param data [Arrays] Partial variables from #easter_aggregate.
      # @return [Array] Partial variables for #easter_end.
      def easter_prepare(year, data)
        a = year % 19
        h, l = data
        [h, l, ((a + (11 * h) + (22 * l)) / 451.0).floor]
      end

      # Final part of Easter calculation.
      #
      # @param data [Fixnum] Variable from #easter_prepare.
      # @return [Array] Day and month of Easter day.
      def easter_end(data)
        h, l, m = data
        [((h + l - (7 * m) + 114) % 31) + 1, ((h + l - (7 * m) + 114) / 31.0).floor]
      end
    end

    # Returns the UTC::Time representation of the current datetime.
    #
    # @return [UTC::Time] The UTC::Time representation of the current datetime.
    def utc_time
      utc.to_time
    end

    # Returns the number of months passed between the beginning of the base year and the current date.
    #
    # ```ruby
    # DateTime.civil(2013, 6, 1).in_months(2011)
    # # => 18
    # ```
    #
    # @param base [DateTime] The base year to start computation from. Default to current year.
    # @return [Fixnum] Returns the number of months passed between the beginning of the base year and the current date.
    def in_months(base = nil)
      (year - (base || ::Date.today.year)) * 12 + month
    end

    # Returns the current month number with leading 0.
    #
    # @return [String] The current month number with leading 0.
    def padded_month
      month.indexize
    end

    # Formats a datetime, looking up also custom formats.
    # @see Settings#setup_date_formats
    #
    # @param format [String] A format or a custom format name to use for formatting.
    # @return [String] The formatted date.
    def lstrftime(format = nil)
      strftime(::DateTime.custom_format(format.to_s).gsub(/(?<!%)(%[ab])/i) { |mo| localize_time_component(mo) })
    end

    # Formats a datetime in the current timezone.
    #
    # @param format [String] The format to use for formatting.
    # @return [String] The formatted date.
    def local_strftime(format = nil)
      (respond_to?(:in_time_zone) ? in_time_zone : self).strftime(::DateTime.custom_format(format))
    end

    # Formats a datetime in the current timezone, looking up also custom formats.
    # @see Settings#setup_date_formats
    #
    # @param format [String] A format or a custom format name.
    # @return [String] The formatted date.
    def local_lstrftime(format = nil)
      (respond_to?(:in_time_zone) ? in_time_zone : self).lstrftime(format)
    end

    private

    # Returns a component of the date in the current locale.
    #
    # @param component [String] The component to localize.
    # @return [String] The localized component.
    def localize_time_component(component)
      type = {"%a" => :short_days, "%A" => :long_days, "%b" => :short_months, "%B" => :long_months}.fetch(component, "")
      index = component =~ /%a/i ? wday : month - 1
      ::Lazier.settings.date_names[type][index]
    end
  end
end

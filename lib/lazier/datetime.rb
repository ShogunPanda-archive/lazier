#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
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
        ::Lazier.settings.date_names[short ? :short_days : :long_days].map.with_index do |label, index|
          {value: (index + 1).to_s, label: label}
        end
      end

      # Returns strings representations of months.
      # @see Settings#setup_date_names
      #
      # @param short [Boolean] If return the abbreviated representations.
      # @return [Array] Return string representations of months.
      def months(short = true)
        ::Lazier.settings.date_names[short ? :short_months : :long_months].map.with_index do |label, index|
          {value: (index + 1).to_s.rjust(2, "0"), label: label}
        end
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
      # @param reference [Fixnum|NilClass] The ending (or middle, if `also_future` is `true`) value of the range. Defaults to the current year.
      # @param as_objects [Boolean] Whether to return years in hashes with `:value` and `label` keys.
      # @return [Array] A range of years. Every entry is
      def years(offset: 10, also_future: true, reference: nil, as_objects: false)
        y = reference || ::Date.today.year
        (y - offset..(also_future ? y + offset : y)).map { |year| as_objects ? {value: year, label: year} : year }
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

      # Returns the Easter (according to Gregorian calendar) date for the year.
      # @see http://en.wikipedia.org/wiki/Computus#Anonymous_Gregorian_algorithm
      #
      # @param year [Fixnum|NilClass] The year to compute the date for. Defaults to the current year.
      # @return [Date] The Easter date for the year.
      def easter(year = nil)
        year = ::Date.today.year unless year.integer?

        # Compute using Anonymous Gregorian Algorithm: http://en.wikipedia.org/wiki/Computus#Anonymous_Gregorian_algorithm
        data = easter_start(year)
        data = easter_divide(data)
        data = easter_aggregate(year, data)
        data = easter_prepare(year, data)
        day, month = easter_end(data)

        ::Date.civil(year, month, day)
      end

      private

      # :nodoc:
      def easter_start(year)
        [year % 19, (year / 100.0).floor, year % 100]
      end

      # :nodoc:
      def easter_divide(data)
        _, b, c = data

        [
          easter_divide_first(b),
          b % 4,
          (c / 4.0).floor,
          c % 4
        ]
      end

      # :nodoc:
      def easter_divide_first(b)
        b - (b / 4.0).floor - ((b - ((b + 8) / 25.0).floor + 1) / 3.0).floor
      end

      # :nodoc:
      def easter_aggregate(year, data)
        a = year % 19
        x, e, i, k = data
        h = ((19 * a) + x + 15) % 30
        [h, (32 + (2 * e) + (2 * i) - h - k) % 7]
      end

      # :nodoc:
      def easter_prepare(year, data)
        a = year % 19
        h, l = data
        [h, l, ((a + (11 * h) + (22 * l)) / 451.0).floor]
      end

      # :nodoc:
      def easter_end(data)
        h, l, m = data
        [((h + l - (7 * m) + 114) % 31) + 1, ((h + l - (7 * m) + 114) / 31.0).floor]
      end
    end

    # Returns the number of months passed between the beginning of the base year and the current date.
    #
    # Example:
    #
    #     DateTime.civil(2013, 6, 1).in_months(2011)
    #     # => 18
    #
    # @param base [DateTime|NilClass] The base year to start computation from. Default to current year.
    # @return [Fixnum] Returns the number of months passed between the beginning of the base year and the current date.
    def months_since_year(base = nil)
      (year - (base || ::Date.today.year)) * 12 + month
    end

    # Returns the current month number with a leading zero if needed.
    #
    # @return [String] The current month number with leading zero if needed.
    def padded_month
      month.indexize
    end

    # Formats a datetime, eventually looking up also custom formats and/or moving to the current timezone.
    # @see Settings#setup_date_formats
    #
    # @param format [String|NilClass] A format or a custom format name to use for formatting.
    # @param custom [Boolean] Whether to use custom formats.
    # @param change_time_zone [Boolean] Whether to move the date to the current timezone.
    # @return [String] The formatted date.
    def format(format = nil, custom: true, change_time_zone: false)
      target = change_time_zone && respond_to?(:in_time_zone) ? in_time_zone : self
      format = custom ? ::DateTime.custom_format(format.to_s).gsub(/(?<!%)(%[ab])/i) { |mo| localize_time_component(mo) } : format.to_s
      target.strftime(format)
    end

    private

    # :nodoc:
    def localize_time_component(component)
      type = {"%a" => :short_days, "%A" => :long_days, "%b" => :short_months, "%B" => :long_months}.fetch(component, "")
      index = component =~ /%a/i ? wday : month - 1

      ::Lazier.settings.date_names[type][index]
    end
  end
end

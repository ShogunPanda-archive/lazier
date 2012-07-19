# encoding: utf-8
#
# This file is part of the cowtech-extensions gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Cowtech
  module Extensions
    # Extensions for date and time objects.
    module DateTime
      extend ActiveSupport::Concern

      # General methods.
      module ClassMethods
        # Returns strings representations of days.
        # @see Settings#setup_date_names
        #
        # @param short [Boolean] If return the abbreviated representations.
        # @return [Array] Return string representations of days.
        def days(short = true)
          days = Cowtech::Extensions.settings.date_names[short ? :short_days : :long_days]
          (1..7).to_a.collect { |i|
            {:value => i.to_s, :label=> days[i - 1]}
          }

        end

        # Returns strings representations of months.
        # @see Settings#setup_date_names
        #
        # @param short [Boolean] If return the abbreviated representations.
        # @return [Array] Return string representations of months.
        def months(short = true)
          months = Cowtech::Extensions.settings.date_names[short ? :short_months : :long_months]
          (1..12).collect { |i|
            {:value => i.to_s.rjust(2, "0"), :label=> months.at(i - 1)}
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
          y = reference || Date.today.year
          (y - offset..(also_future ? y + offset : y)).collect { |year| as_objects ? {:value => year, :label => year} : year }
        end

        # Returns the Easter (according to Gregorian calendar) date for the year.
        # @see http://en.wikipedia.org/wiki/Computus#Anonymous_Gregorian_algorithm
        #
        # @param year [Fixnum] The year to compute the date for. Defaults to the current year.
        # @return [Date] The Easter date for the year.
        def easter(year = nil)
          year = Date.today.year if !year.is_integer?

          # Compute using Anonymouse Gregorian Algorithm: http://en.wikipedia.org/wiki/Computus#Anonymous_Gregorian_algorithm
          a = year % 19
          b = (year / 100.0).floor
          c = year % 100
          d = (b / 4.0).floor
          e = b % 4
          f = ((b + 8) / 25.0).floor
          g = ((b - f + 1) / 3.0).floor
          h = ((19 * a) + b - d - g + 15) % 30
          i = (c / 4.0).floor
          k = c % 4
          l = (32 + (2 * e) + (2 * i) - h - k) % 7
          m = ((a + (11 * h) + (22 * l)) / 451.0).floor

          day = ((h + l - (7 * m) + 114) % 31) + 1
          month = ((h + l - (7 * m) + 114) / 31.0).floor
          Date.civil(year, month, day)
        end

        # Lookups a custom datetime format.
        # @see Settings#setup_date_formats
        #
        # @param key [Symbol] The name of the format to search.
        # @return [String] The format or the name itself (if the format has not been found).
        def custom_format(key)
          Cowtech::Extensions.settings.date_formats.fetch(key.to_sym, key).ensure_string
        end

        # Checks if the date is valid against to a specific format.
        # @see DateTime#custom_format.
        #
        # @param value [String] The value to check.
        # @param format [String] The format to check the value against.
        # @return [Boolean] `true` if the value is valid against the format, `false` otherwise.
        def is_valid?(value, format = "%F %T")
          rv = true

          format = self.custom_format(format)

          begin
            ::DateTime.strptime(value.ensure_string, format)
          rescue => e
            rv = false
          end

          rv
        end

        # Returns the rational offset for a timezone.
        #
        # ```ruby
        # DateTime.rational_offset(ActiveSupport::TimeZone["Mountain Time (US & Canada)"])
        # # => (-7/24)
        # ```
        #
        # @param tz [TimeZone] The zone to handle.
        # @return [Rational] The rational offset of the timezone.
        def rational_offset(tz = ::Time.zone)
          Rational((tz.tzinfo.current_period.utc_offset / 3600), 24)
        end

        # Returns a string representation of a timezone
        #
        # ```ruby
        # DateTime.parameterize_zone(ActiveSupport::TimeZone["Pacific Time (US & Canada)"])
        # # => "-0800@pacific-time-us-canada"
        # ```
        # @param tz [TimeZone] The zone to represent.
        # @return [String] A string representation which can be used for searches.
        def parameterize_zone(tz)
          tz = tz.to_s if !tz.is_a?(String)

          if tz =~ /^(\([a-z]+([+-])(\d{2}):(\d{2})\)\s(.+))$/i then
            "#{$2}#{$3}#{$4}@#{$5.parameterize}"
          else
            tz.parameterize
          end
        end

        # Finds a parameterized timezone.
        # @see DateTime#parameterize_zone.
        #
        # @param tz [String] The zone to represent.
        # @param as_string [Boolean] If return just the zone name.
        # @return [String|TimeZone] The found timezone or `nil` if the zone is not valid.
        def find_parameterized_zone(tz, as_string = false)
          tz = Date.parameterize_zone(tz) if !tz.is_a?(String)
          tz = tz.gsub(/^(.+\d{4}@)?/, "")

          rv = catch(:zone) do
            ActiveSupport::TimeZone::MAPPING.each_key do |zone|
              throw(:zone, zone) if ::DateTime.parameterize_zone(zone) == tz
            end

            nil
          end

          if rv then
            (as_string ? rv : ActiveSupport::TimeZone[rv])
          else
            nil
          end
        end
      end

      # Returns the UTC::Time representation of the current datetime.
      #
      # @return [UTC::Time] The UTC::Time representation of the current datetime.
      def utc_time
        ua = (self.respond_to?(:utc) ? self : self.to_datetime).utc
        ::Time.utc(ua.year, ua.month, ua.day, ua.hour, ua.min, ua.sec)
      end

      # Returns the number of months passed between the beginning of the base year and the current date.
      #
      # ```ruby
      # DateTime.civil(2012, 6, 1).in_months(2011)
      # # => 18
      # ```
      #
      # @param base [DateTime] The base year to start computation from. Default to current year.
      # @return [Fixnum] Returns the number of months passed between the beginning of the base year and the current date.
      def in_months(base = nil)
        base ||= Date.today.year
        ((self.year) - base) * 12 + self.month
      end

      # Returns the current month number with leading 0.
      #
      # @return [String] The current month number with leading 0.
      def padded_month
        self.month.to_s.rjust(2, "0")
      end

      # Formats a datetime, looking up also custom formats.
      # @see Settings#setup_date_formats
      #
      # @param format [String] A format or a custom format name to use for formatting.
      # @return [String] The formatted date.
      def lstrftime(format = nil)
        rv = nil
        names = Cowtech::Extensions.settings.date_names

        final_format = ::DateTime.custom_format(format).ensure_string.gsub(/(%{1,2}:?[abz])/i) do |match|
          mrv = match

          # Handling of %z is to fix ruby 1.8 bug in OSX: http://bugs.ruby-lang.org/issues/2396
          if match !~ /^%%/ then
            case match
              when "%a"
                mrv = names[:short_days][self.wday]
              when "%A"
                mrv = names[:long_days][self.wday]
              when "%b"
                mrv = names[:short_months][self.month - 1]
              when "%B"
                mrv = names[:long_months][self.month - 1]
              when "%z"
                mrv = Cowtech::Extensions.is_ruby_18? ? self.formatted_offset(false) : nil
              when "%:z"
                mrv = Cowtech::Extensions.is_ruby_18? ? self.formatted_offset(true) : nil
            end
          end

          mrv ? mrv.sub("%", "%%") : match
        end

        self.strftime(final_format)
      end

      # Formats a datetime in the current timezone.
      #
      # @param format [String] The format to use for formatting.
      # @return [String] The formatted date.
      def local_strftime(format = nil)
        (self.respond_to?(:in_time_zone) ? self.in_time_zone : self).strftime(::DateTime.custom_format(format))
      end

      # Formats a datetime in the current timezone, looking up also custom formats.
      # @see Settings#setup_date_formats
      #
      # @param format [String] A format or a custom format name.
      # @return [String] The formatted date.
      def local_lstrftime(format = nil)
        (self.respond_to?(:in_time_zone) ? self.in_time_zone : self).lstrftime(format)
      end
    end
  end
end

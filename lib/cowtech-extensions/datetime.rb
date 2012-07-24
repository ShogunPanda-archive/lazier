# encoding: utf-8
#
# This file is part of the cowtech-extensions gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Cowtech
  module Extensions
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
          days = ::Cowtech::Extensions.settings.date_names[short ? :short_days : :long_days]
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
          months = ::Cowtech::Extensions.settings.date_names[short ? :short_months : :long_months]
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
          y = reference || ::Date.today.year
          (y - offset..(also_future ? y + offset : y)).collect { |year| as_objects ? {:value => year, :label => year} : year }
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
          ::ActiveSupport::TimeZone::parameterize_zone(tz, with_offset)
        end

        # Finds a parameterized timezone.
        # @see DateTime#parameterize_zone
        #
        # @param tz [String] The zone to unparameterize.
        # @param as_string [Boolean] If return just the zone name.
        # @param dst_label [String] Label for the DST indication. Defaults to `(DST)`.
        # @return [String|TimeZone] The found timezone or `nil` if the zone is not valid.
        def unparameterize_zone(tz, as_string = false, dst_label = nil)
          ::ActiveSupport::TimeZone::unparameterize_zone(tz, as_string, dst_label)
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
          year = ::Date.today.year if !year.is_integer?

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
          ::Date.civil(year, month, day)
        end

        # Lookups a custom datetime format.
        # @see Settings#setup_date_formats
        #
        # @param key [Symbol] The name of the format to search.
        # @return [String] The format or the name itself (if the format has not been found).
        def custom_format(key)
          ::Cowtech::Extensions.settings.date_formats.fetch(key.to_sym, key).ensure_string
        end

        # Checks if the date is valid against to a specific format.
        # @see DateTime#custom_format
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
        base ||= ::Date.today.year
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
        names = ::Cowtech::Extensions.settings.date_names

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
                mrv = ::Cowtech::Extensions.is_ruby_18? ? self.formatted_offset(false) : nil
              when "%:z"
                mrv = ::Cowtech::Extensions.is_ruby_18? ? self.formatted_offset(true) : nil
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

    # Extensions for timezone objects.
    module TimeZone
      extend ::ActiveSupport::Concern

      # General methods.
      module ClassMethods
        # Returns an offset in rational value.
        #
        # @param offset [Fixnum] The offset to convert.
        # @return [Rational] The converted offset.
        def rationalize_offset(offset)
          offset = offset.try(:offset) if !offset.is_a?(::Fixnum)
          ::TZInfo::OffsetRationals.rational_for_offset(offset.to_integer)
        end

        # Returns a +HH:MM formatted representation of the offset.
        #
        # @param offset [Rational|Fixnum] The offset to represent, in seconds or as a rational.
        # @param colon [Boolean] If to put the colon in the output string.
        # @return [String] The formatted offset.
        def format_offset(offset, colon = true)
          offset = (offset * 86400).to_i if offset.is_a?(::Rational)
          offset.is_a?(::Fixnum) ? self.seconds_to_utc_offset(offset, colon) : nil
        end

        # Find a zone by its name.
        #
        # @param name [String] The zone name.
        # @param dst_label [String] Label for the DST indication. Defaults to `(DST)`.
        # @return [TimeZone] A timezone or `nil` if no zone was found.
        def find(name, dst_label = nil)
          catch(:zone) do
            ::ActiveSupport::TimeZone.all.each do |zone|
              zone.aliases.each do |zone_alias|
                throw(:zone, zone) if [zone.to_str(zone_alias), zone.to_str_with_dst(dst_label, nil, zone_alias)].include?(name)
              end
            end

            nil
          end
        end

        # Returns a list of names of all timezones.
        #
        # @param with_dst [Boolean] If include DST version of the zones.
        # @param dst_label [String] Label for the DST indication. Defaults to `(DST)`.
        # @return [Array] A list of names of timezones.
        def list_all(with_dst = true, dst_label = nil)
          dst_label ||= "(DST)"
          dst_key = "DST-#{dst_label}"
          @zones_names ||= { "STANDARD" => ::ActiveSupport::TimeZone.all.collect(&:to_s) }

          if with_dst && @zones_names[dst_key].blank? then
            @zones_names[dst_key] = []

            ::ActiveSupport::TimeZone.all.each do |zone|
              zone.aliases.each do |zone_alias|
                @zones_names[dst_key] << zone.to_str(zone_alias)
                @zones_names[dst_key] << zone.to_str_with_dst(dst_label, nil, zone_alias) if zone.uses_dst? && zone_alias !~ /(#{Regexp.quote(dst_label)})$/
              end
            end

            @zones_names[dst_key]= @zones_names[dst_key].uniq.compact.sort { |a,b| ::ActiveSupport::TimeZone.compare(a, b) } # Sort by name
          end

          @zones_names[with_dst ? dst_key : "STANDARD"]
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
          tz = tz.to_s if !tz.is_a?(::String)

          if tz =~ /^(\([a-z]+([+-])(\d{2})(:?)(\d{2})\)\s(.+))$/i then
            with_offset ? "#{$2}#{$3}#{$5}@#{$6.parameterize}" : $6.parameterize
          elsif !with_offset then
            tz.gsub(/^([+-]?(\d{2})(:?)(\d{2})@)/, "")
          else
            tz.parameterize
          end
        end

        # Finds a parameterized timezone.
        # @see DateTime#parameterize_zone
        #
        # @param tz [String] The zone to unparameterize.
        # @param as_string [Boolean] If return just the zone name.
        # @param dst_label [String] Label for the DST indication. Defaults to `(DST)`.
        # @return [String|TimeZone] The found timezone or `nil` if the zone is not valid.
        def unparameterize_zone(tz, as_string = false, dst_label = nil)
          tz = self.parameterize_zone(tz, false)
          rv = catch(:zone) do
            self.list_all(true, dst_label).each do |zone|
              throw(:zone, zone) if self.parameterize_zone(zone, false) =~ /(#{Regexp.quote(tz)})$/
            end

            nil
          end

          if rv then
            (as_string ? rv : self.find(rv, dst_label))
          else
            nil
          end
        end

        # Compares two timezones. They are sorted by the location name.
        #
        # @param left [String|TimeZone] The first zone name to compare.
        # @param right [String|TimeZone] The second zone name to compare.
        # @return [Fixnum] The result of comparison, like Ruby's operator `<=>`.
        def compare(left, right)
          left = left.to_str if left.is_a?(::ActiveSupport::TimeZone)
          right = right.to_str if right.is_a?(::ActiveSupport::TimeZone)
          left.ensure_string.split(" ", 2)[1] <=> right.ensure_string.split(" ", 2)[1]
        end
      end

      # Returns a list of valid aliases (city names) for this timezone (basing on offset).
      #
      # @param dst_label [String] Label for the DST indication. Defaults to `(DST)`.
      # @return [Array] A list of aliases for this timezone
      def aliases(dst_label = nil)
        reference = self.name
        reference = self.class::MAPPING[self.name] if self.class::MAPPING.has_key?(self.name) # We are an alias
        reference = reference.gsub("_", " ")

        if @aliases.blank? then
          # First we search for aliases by name
          @aliases = [reference]

          self.class::MAPPING.each do |name, zone|
            if zone.gsub("_", " ") == reference then
              if name == "International Date Line West" || name == "UTC" || name.include?("(US & Canada)")
                @aliases << name
              else
                @aliases << reference.gsub(/\/.*/, "/" + name)
              end
            end
          end

          @aliases = @aliases.uniq.compact.sort
        end

        @aliases
      end

      # Returns the current offset for this timezone, taking care of DST (DST).
      #
      # @param rational [Boolean] If to return the offset as a Rational.
      # @param date [DateTime] The date to consider. Defaults to now.
      # @return [Fixnum|Rational] The offset of this timezone.
      def current_offset(rational = false, date = nil)
        date ||= ::DateTime.now

        dst_period = self.dst_period

        rv = (self.period_for_utc(date.utc).dst? ? self.dst_offset : self.offset)
        rational ? self.class.rationalize_offset(rv) : rv
      end

      # Returns the standard offset for this timezone.
      #
      # @param rational [Boolean] If to return the offset as a Rational.
      # @return [Fixnum|Rational] The offset of this timezone.
      def offset(rational = false)
        rv = self.utc_offset
        rational ? self.class.rationalize_offset(rv) : rv
      end

      # Gets a period for this timezone when the DST (DST) is active (it takes care of different hemispheres).
      #
      # @param year [Fixnum] The year to which refer to. Defaults to the current year.
      # @return [TimezonePeriod] A period when the DST (DST) is active or `nil` if the timezone doesn't use DST for that year.
      def dst_period(year = nil)
        year ||= ::Date.today.year

        nothern_summer = ::DateTime.civil(year, 7, 15).utc # This is a representation of a summer period in the Northern Hemisphere.
        southern_summer = ::DateTime.civil(year, 1, 15).utc # This is a representation of a summer period in the Northern Hemisphere.

        period = self.period_for_utc(nothern_summer)
        period = self.period_for_utc(southern_summer) if !period.dst?
        period.dst? ? period : nil
      end

      # Checks if the timezone uses DST (DST) for that year.
      #
      # @param year [Fixnum] The year to check. Defaults to the current year.
      # @return [Boolean] `true` if the zone uses DST, `false` otherwise.
      def uses_dst?(year = nil)
        self.dst_period(year).present?
      end

      # Return the correction applied to the standard offset the timezone when the DST (DST) is active.
      #
      # @param rational [Boolean] If to return the offset as a Rational.
      # @param year [Fixnum] The year to which refer to. Defaults to the current year.
      # @return [Fixnum|Rational] The correction for dst.
      def dst_correction(rational = false, year = nil)
        period = self.dst_period(year)
        rv = period ? period.std_offset : 0
        rational ? self.class.rationalize_offset(rv) : rv
      end

      # Returns the standard offset for this timezone timezone when the DST (DST) is active.
      #
      # @param rational [Boolean] If to return the offset as a Rational.
      # @param year [Fixnum] The year to which refer to. Defaults to the current year.
      # @return [Fixnum|Rational] The DST offset for this timezone or `0`, if the timezone doesn't use DST for that year.
      def dst_offset(rational = false, year = nil)
        period = self.dst_period(year)
        rv = period ? period.utc_total_offset : 0
        rational ? self.class.rationalize_offset(rv) : rv
      end

      # Returns the name for this zone with DST (DST) active.
      #
      # @param dst_label [String] Label for the DST indication. Defaults to `(DST)`.
      # @param year [Fixnum] The year to which refer to. Defaults to the current year.
      # @param name [String] The name to use for this zone. Defaults to the zone name.
      # @return [String] The name for the zone with DST or `nil`, if the timezone doesn't use DST for that year.
      def dst_name(dst_label = nil, year = nil, name = nil)
        dst_label ||= "(DST)"
        name ||= self.name

        self.uses_dst?(year) ? "#{name} #{dst_label}" : nil
      end

      # Returns the name for this zone with DST (DST) active.
      #
      # @param name [String] The name to use for this zone. Defaults to the zone name.
      # @param colon [Boolean] If to put the colon in the output string.
      # @return [String] The name for this zone.
      def to_str(name = nil, colon = true)
        name ||= self.aliases.first
        "(GMT#{self.formatted_offset(colon)}) #{name}"
      end

      # Returns a string representation for this zone with DST (DST) active.
      #
      # @param dst_label [String] Label for the DST indication. Defaults to `(DST)`.
      # @param year [Fixnum] The year to which refer to. Defaults to the current year.
      # @param name [String] The name to use for this zone. Defaults to the zone name.
      # @return [String] The string representation for the zone with DST or `nil`, if the timezone doesn't use DST for that year.
      def to_str_with_dst(dst_label = nil, year = nil, name = nil)
        dst_label ||= "(DST)"
        name ||= self.aliases.first

        if self.uses_dst?(year) then
          period = self.dst_period(year)
          offset = self.class.seconds_to_utc_offset(period.utc_total_offset)
          "(GMT#{offset}) #{name} #{dst_label}"
        else
          nil
        end
      end

      # Returns a parametized string representation for this zone.
      #
      # @param with_offset [Boolean] If to include offset into the representation.
      # @param name [String] The name to use for this zone. Defaults to the zone name.
      # @return [String] The parametized string representation for this zone.
      def to_str_parameterized(with_offset = true, name = nil)
        ::ActiveSupport::TimeZone.parameterize_zone(name || self.to_str, with_offset)
      end

      # Returns a parametized string representation for this zone with DST (DST) active.
      #
      # @param dst_label [String] Label for the DST indication. Defaults to `(DST)`.
      # @param with_offset [Boolean] If to include offset into the representation.
      # @param year [Fixnum] The year to which refer to. Defaults to the current year.
      # @param name [String] The name to use for this zone. Defaults to the zone name.
      # @return [String] The parametized string representation for this zone with DST or `nil`, if the timezone doesn't use DST for that year.
      def to_str_with_dst_parameterized(dst_label = nil, with_offset = true, year = nil, name = nil)
        rv = self.to_str_with_dst(dst_label, year, name)
        rv ? ::ActiveSupport::TimeZone.parameterize_zone(rv) : nil
      end
    end
  end
end

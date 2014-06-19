# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Lazier
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
        ::TZInfo::OffsetRationals.rational_for_offset(offset.is_a?(::Fixnum) ? offset : offset.offset)
      end

      # Returns a +HH:MM formatted representation of the offset.
      #
      # @param offset [Rational|Fixnum] The offset to represent, in seconds or as a rational.
      # @param colon [Boolean] If to put the colon in the output string.
      # @return [String] The formatted offset.
      def format_offset(offset, colon = true)
        seconds_to_utc_offset(offset.is_a?(::Rational) ? (offset * 86_400).to_i : offset, colon)
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
              if [zone.to_str(zone_alias), zone.to_str_with_dst(dst_label, nil, zone_alias)].include?(name)
                zone.current_alias = zone_alias
                throw(:zone, zone)
              end
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

        @zones_names ||= { "STANDARD" => ::ActiveSupport::TimeZone.all.map(&:to_s) }
        @zones_names["DST[#{dst_label}]-STANDARD"] ||= ::ActiveSupport::TimeZone.all
        .map { |zone| fetch_aliases(zone, dst_label) }.flatten.compact.uniq
        .sort { |a, b| ::ActiveSupport::TimeZone.compare(a, b) } # Sort by name

        @zones_names["#{with_dst ? "DST[#{dst_label}]-" : ""}STANDARD"]
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
        tz = tz.to_s unless tz.is_a?(::String)
        mo = /^(\([a-z]+([+-])(\d{2})(:?)(\d{2})\)\s(.+))$/i.match(tz)

        if mo
          with_offset ? "#{mo[2]}#{mo[3]}#{mo[5]}@#{mo[6].to_s.parameterize}" : mo[6].to_s.parameterize
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
        tz = parameterize_zone(tz, false)
        rv = find_parameterized_zone(dst_label, /(#{Regexp.quote(tz)})$/)

        if rv
          as_string ? rv : find(rv, dst_label)
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

      private

      # Returns a list of aliases for a given time zone.
      #
      # @param zone [ActiveSupport::TimeZone] The zone.
      # @param dst_label [String] Label for the DST indication. Defaults to `(DST)`.
      def fetch_aliases(zone, dst_label = "(DST)")
        matcher = /(#{Regexp.quote(dst_label)})$/

        zone.aliases.map { |zone_alias|
          [zone.to_str(zone_alias), (zone.uses_dst? && zone_alias !~ matcher) ? zone.to_str_with_dst(dst_label, nil, zone_alias) : nil]
        }
      end

      # Finds a parameterized timezone.
      #
      # @param dst_label [String] Label for the DST indication. Defaults to `(DST)`.
      # @param matcher [Regexp] The expression to match.
      # @return [String] The found timezone or `nil` if the zone is not valid.
      def find_parameterized_zone(dst_label, matcher)
        catch(:zone) do
          list_all(true, dst_label).each do |zone|
            throw(:zone, zone) if parameterize_zone(zone, false) =~ matcher
          end

          nil
        end
      end
    end

    # Returns a list of valid aliases (city names) for this timezone (basing on offset).
    # @return [Array] A list of aliases for this timezone
    def aliases
      reference = self.class::MAPPING.fetch(name, name).gsub("_", " ")
      @aliases ||= ([reference] + self.class::MAPPING.map { |name, zone| format_alias(name, zone, reference) }).uniq.compact.sort
    end

    # Returns the current offset for this timezone, taking care of Daylight Saving Time (DST).
    #
    # @param rational [Boolean] If to return the offset as a Rational.
    # @param date [DateTime] The date to consider. Defaults to now.
    # @return [Fixnum|Rational] The offset of this timezone.
    def current_offset(rational = false, date = nil)
      date ||= ::DateTime.now
      rv = (period_for_utc(date.utc).dst? ? dst_offset : offset)
      rational ? self.class.rationalize_offset(rv) : rv
    end

    # Returns the current alias for this timezone.
    #
    # @return [String] The current alias or the first alias of the current timezone.
    def current_alias
      if @current_alias
        @current_alias
      else
        identifier = tzinfo.identifier

        catch(:alias) do
          aliases.each do |a|
            throw(:alias, a) if a == identifier
          end

          aliases.first
        end
      end
    end

    # Sets the current alias.
    #
    # @param new_alias [String] The new current alias.
    def current_alias=(new_alias)
      @current_alias = new_alias.ensure_string
    end

    # Returns the standard offset for this timezone.
    #
    # @param rational [Boolean] If to return the offset as a Rational.
    # @return [Fixnum|Rational] The offset of this timezone.
    def offset(rational = false)
      rational ? self.class.rationalize_offset(utc_offset) : utc_offset
    end

    # Gets a period for this timezone when the Daylight Saving Time (DST) is active (it takes care of different hemispheres).
    #
    # @param year [Fixnum] The year to which refer to. Defaults to the current year.
    # @return [TimezonePeriod] A period when the Daylight Saving Time (DST) is active or `nil` if the timezone doesn't use DST for that year.
    def dst_period(year = nil)
      year ||= ::Date.today.year

      northern_summer = ::DateTime.civil(year, 7, 15).utc # This is a representation of a summer period in the Northern Hemisphere.
      southern_summer = ::DateTime.civil(year, 1, 15).utc # This is a representation of a summer period in the Southern Hemisphere.

      period = period_for_utc(northern_summer)
      period = period_for_utc(southern_summer) unless period.dst?
      period.dst? ? period : nil
    end

    # Checks if the timezone uses Daylight Saving Time (DST) for that date or year.
    #
    # @param reference [Object] The date or year to check. Defaults to the current year.
    # @return [Boolean] `true` if the zone uses DST for that date or year, `false` otherwise.
    def uses_dst?(reference = nil)
      if reference.respond_to?(:year) && reference.respond_to?(:utc) # This is a date like object
        dst_period(reference.year).present? && period_for_utc(reference.utc).dst?
      else
        dst_period(reference).present?
      end
    end

    # Return the correction applied to the standard offset the timezone when the Daylight Saving Time (DST) is active.
    #
    # @param rational [Boolean] If to return the offset as a Rational.
    # @param year [Fixnum] The year to which refer to. Defaults to the current year.
    # @return [Fixnum|Rational] The correction for dst.
    def dst_correction(rational = false, year = nil)
      dst_offset(rational, year, :std_offset)
    end

    # Returns the standard offset for this timezone timezone when the Daylight Saving Time (DST) is active.
    #
    # @param rational [Boolean] If to return the offset as a Rational.
    # @param year [Fixnum] The year to which refer to. Defaults to the current year.
    # @param method [Symbol] The method to use for getting the offset. Default is total offset from UTC.
    # @return [Fixnum|Rational] The DST offset for this timezone or `0`, if the timezone doesn't use DST for that year.
    def dst_offset(rational = false, year = nil, method = :utc_total_offset)
      period = dst_period(year)
      rv = period ? period.send(method) : 0
      rational ? self.class.rationalize_offset(rv) : rv
    end

    # Returns the name for this zone with Daylight Saving Time (DST) active.
    #
    # @param dst_label [String] Label for the DST indication. Defaults to `(DST)`.
    # @param year [Fixnum] The year to which refer to. Defaults to the current year.
    # @param name [String] The name to use for this zone. Defaults to the zone name.
    # @return [String] The name for the zone with DST or `nil`, if the timezone doesn't use DST for that year.
    def dst_name(dst_label = nil, year = nil, name = nil)
      uses_dst?(year) ? "#{name || self.name} #{dst_label || "(DST)"}" : nil
    end

    # Returns the name for this zone with Daylight Saving Time (DST) active.
    #
    # @param name [String] The name to use for this zone. Defaults to the zone name.
    # @param colon [Boolean] If to put the colon in the output string.
    # @return [String] The name for this zone.
    def to_str(name = nil, colon = true)
      "(GMT#{formatted_offset(colon)}) #{name || current_alias}"
    end

    # Returns a string representation for this zone with Daylight Saving Time (DST) active.
    #
    # @param dst_label [String] Label for the DST indication. Defaults to `(DST)`.
    # @param year [Fixnum] The year to which refer to. Defaults to the current year.
    # @param name [String] The name to use for this zone. Defaults to the zone name.
    # @return [String] The string representation for the zone with DST or `nil`, if the timezone doesn't use DST for that year.
    def to_str_with_dst(dst_label = nil, year = nil, name = nil)
      uses_dst?(year) ? "(GMT#{self.class.seconds_to_utc_offset(dst_period(year).utc_total_offset)}) #{name || current_alias} #{dst_label || "(DST)"}" : nil
    end

    # Returns a parameterized string representation for this zone.
    #
    # @param with_offset [Boolean] If to include offset into the representation.
    # @param name [String] The name to use for this zone. Defaults to the zone name.
    # @return [String] The parameterized string representation for this zone.
    def to_str_parameterized(with_offset = true, name = nil)
      ::ActiveSupport::TimeZone.parameterize_zone(name || to_str, with_offset)
    end

    # Returns a parameterized string representation for this zone with Daylight Saving Time (DST) active.
    #
    # @param dst_label [String] Label for the DST indication. Defaults to `(DST)`.
    # @param year [Fixnum] The year to which refer to. Defaults to the current year.
    # @param name [String] The name to use for this zone. Defaults to the zone name.
    # @return [String] The parameterized string representation for this zone with DST or `nil`, if the timezone doesn't use DST for that year.
    def to_str_with_dst_parameterized(dst_label = nil, year = nil, name = nil)
      rv = to_str_with_dst(dst_label, year, name)
      rv ? ::ActiveSupport::TimeZone.parameterize_zone(rv) : nil
    end

    private

    # Formats a time zone alias.
    #
    # @param name [String] The zone name.
    # @param zone [String] The zone.
    # @param reference [String] The main name for the zone.
    # @return [String|nil] The formatted alias.
    def format_alias(name, zone, reference)
      if zone.gsub("_", " ") == reference
        ["International Date Line West", "UTC"].include?(name) || name.include?("(US & Canada)") ? name : reference.gsub(/\/.*/, "/#{name}")
      else
        nil
      end
    end
  end
end

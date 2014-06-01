#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Lazier
  # Extensions for timezone objects.
  module TimeZone
    extend ::ActiveSupport::Concern

    # Pattern for a parameterized timezone.
    ALREADY_PARAMETERIZED = /^[+-]\d{4}@[a-z-]+/

    # Pattern for a unparameterized timezone.
    PARAMETERIZER = /^(
      \(
        [a-z]+ # UTC Label
        (?<offset>([+-])(\d{2})(:?)(\d{2}))
      \)
      \s
      (?<label>.+)
    )$/xi

    # General methods.
    module ClassMethods
      # Expression to parameterize a zone
      # Returns an offset in rational value.
      #
      # @param offset [Fixnum] The offset to convert.
      # @return [Rational] The converted offset.
      def rationalize_offset(offset)
        ::TZInfo::OffsetRationals.rational_for_offset(offset)
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
      # @param dst_label [String] Label for the DST indication. Defaults to ` (DST)`.
      # @return [TimeZone] A timezone or `nil` if no zone was found.
      def find(name, dst_label = " (DST)")
        list(true, dst_label: dst_label, as_hash: true)[name]
      end

      # Returns a list of names of all timezones.
      #
      # @param with_dst [Boolean] If include DST version of the zones.
      # @param parameterized [Boolean] If parameterize zones.
      # @param dst_label [String] Label for the DST indication. Defaults to ` (DST)`.
      # @param as_hash [Hash] If return an hash.
      # @return [Array|Hash] A list of names of timezones or a hash with labels and timezones as keys.
      def list(with_dst = true, dst_label: " (DST)", parameterized: false, sort_by_name: true, as_hash: false)
        dst_label = nil unless with_dst
        key = [dst_label, sort_by_name, as_hash, parameterized].join(":")
        @zones_names ||= {}

        unless @zones_names[key]
          all = ::ActiveSupport::TimeZone.all
          @zones_names[key] = send("finalize_list_as_#{as_hash ? "hash" : "list"}", all, dst_label, parameterized, sort_by_name)
        end

        @zones_names[key]
      end

      # Returns a string representation of a timezone.
      #
      # ```ruby
      # DateTime.parameterize_zone(ActiveSupport::TimeZone["Pacific Time (US & Canada)"])
      # # => "-0800@pacific-time-us-canada"
      # ```
      # @param tz [TimeZone|String] The zone to represent.
      # @param with_offset [Boolean] If to include offset into the representation.
      # @return [String] A string representation which can be used for searches.
      def parameterize(tz, with_offset = true)
        tz = tz.to_str unless tz.is_a?(::String)

        if tz =~ ::Lazier::TimeZone::ALREADY_PARAMETERIZED
          tz
        elsif tz =~ ::Lazier::TimeZone::PARAMETERIZER
          mo = $LAST_MATCH_INFO
          [(with_offset ? mo[:offset].gsub(":", "") : nil), mo[:label].parameterize].compact.join("@")
        else
          tz.parameterize
        end
      end

      # Finds a parameterized timezone.
      # @see DateTime#parameterize_zone
      #
      # @param tz [String] The zone to unparameterize.
      # @param dst_label [String] Label for the DST indication. Defaults to `(DST)`.
      # @return [TimeZone] The found timezone or `nil` if the zone is not valid.
      def unparameterize(tz, dst_label = " (DST)")
        tz = parameterize(tz)
        list(true, dst_label: dst_label, parameterized: true, as_hash: true)[tz]
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

      # :nodoc:
      def fetch_aliases(zone, dst_label = "(DST)", parameterized = false)
        zone.aliases.map { |zone_alias|
          [
            zone.to_str(false, label: zone_alias, parameterized: parameterized),
            (zone.uses_dst? && dst_label) ? zone.to_str(true, label: zone_alias, dst_label: dst_label, parameterized: parameterized) : nil
          ]
        }.flatten.uniq.compact
      end

      # :nodoc:
      def finalize_list_as_list(all, dst_label, parameterized, sort_by_name)
        rv = all.map { |zone|
          fetch_aliases(zone, dst_label, parameterized)
        }.flatten.uniq

        sort_by_name ? rv.sort { |a, b| ::ActiveSupport::TimeZone.compare(a, b) } : rv
      end

      # :nodoc:
      def finalize_list_as_hash(all, dst_label, parameterized, sort_by_name)
        rv = all.reduce({}) { |accu, zone|
          accu.merge(fetch_aliases(zone, dst_label, parameterized).reduce({}) { |a, e|
            a[e] = zone
            a
          })
        }

        sort_by_name ? ::Hash[rv.sort { |a, b| ::ActiveSupport::TimeZone.compare(a[0], b[0]) }] : rv
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
      date = (date || ::DateTime.current).in_time_zone
      offset(rational: rational, dst: date.dst?, year: date.year)
    end

    # Returns the current alias for this timezone.
    #
    # @return [String] The current alias or the first alias of the current timezone.
    def current_alias
      identifier = name

      catch(:alias) do
        aliases.each do |a|
          throw(:alias, a) if a == identifier
        end

        aliases.first
      end
    end

    # Returns the current name.
    #
    # @param dst [Boolean] If to return the name with DST indication.
    # @param dst_label [String] Label for the DST indication. Defaults to ` (DST)`.
    # @param year [Fixnum] The year to which refer to. Defaults to the current year. *Only required when `dst` is true*.
    # @return [String] The name for the zone.
    def current_name(dst = false, dst_label: " (DST)", year: nil)
      year ||= Date.current.year
      rv = current_alias
      rv += dst_label if dst && uses_dst?(year)
      rv
    end

    # Returns the standard offset for this timezone.
    #
    # @param rational [Boolean] If to return the offset as a Rational.
    # @param dst [Boolean] If to return the offset when the DST is active.
    # @param year [Fixnum] The year to which refer to. Defaults to the current year.
    # @return [Fixnum|Rational] The offset of this timezone.
    def offset(rational: false, dst: false, year: nil)
      rv =
        if dst
          period = dst_period(year)
          period ? period.utc_total_offset : 0
        else
          utc_offset
        end

      rational ? self.class.rationalize_offset(rv) : rv
    end

    # Checks if the timezone uses Daylight Saving Time (DST) for that date or year.
    #
    # @param reference [Date|DateTime] The date or year to check. Defaults to the current year.
    # @return [Boolean] `true` if the zone uses DST for that date or year, `false` otherwise.
    def uses_dst?(reference = nil)
      if reference.is_a?(Date) || reference.is_a?(DateTime) || reference.is_a?(Time)
        period_for_utc(reference).dst?
      else
        dst_period(reference)
      end
    end

    # Gets a period for this timezone when the Daylight Saving Time (DST) is active (it takes care of different hemispheres).
    #
    # @param year [Fixnum] The year to which refer to. Defaults to the current year.
    # @return [TimezonePeriod] A period when the Daylight Saving Time (DST) is active or `nil` if the timezone doesn't use DST for that year.
    def dst_period(year = nil)
      year ||= ::Date.current.year

      period = period_for_utc(::DateTime.civil(year, 7, 15, 12).utc) # Summer for the northern hemisphere
      period = period_for_utc(::DateTime.civil(year, 1, 15, 12).utc) unless period.dst? # Summer for the southern hemisphere
      period.dst? ? period : nil
    rescue
      nil
    end

    # Return the correction applied to the standard offset the timezone when the Daylight Saving Time (DST) is active.
    #
    # @param rational [Boolean] If to return the offset as a Rational.
    # @param year [Fixnum] The year to which refer to. Defaults to the current year.
    # @return [Fixnum|Rational] The correction for dst.
    def dst_correction(rational = false, year = nil)
      rv = dst_offset(year, :std_offset)
      rational ? self.class.rationalize_offset(rv) : rv
    end

    # Formats this zone as a string.
    #
    # @param dst [Boolean] If to represent with (DST) active.
    # @param args [Hash] Parameters for the formatting:
    #
    #   * **label** (`String`): The label to use. Default to the current alias.
    #   * **dst_label** (`String`): Label for the DST indication. Defaults to ` (DST)`.
    #   * **utc_label** (`String`): Label for the UTC name. Defaults to `GMT`. *Only used when `parameterized` is `false`.
    #   * **year** (`Fixnum`): The year to which refer to. Defaults to the current year.
    #   * **parameterized** (`Boolean`): If to represent as parameterized.
    #   * **with_offset** (`Boolean`): If to include offset into the representation. *Only used when `parameterized` is `true`.
    #   * **offset_position** (`Symbol`): Where to put the offset. Valid values are `:begin` or `:end`. *Only used when `parameterized` is `false`.
    #   * **colon** (`Boolean`): If include a colon in the offset. *Only used when `parameterized` is `false`.
    #
    # @return [String] The string representation for this zone.
    def to_str(dst = false, **args)
      # PI: Ignore reek on this.
      label, dst_label, utc_label, year, parameterized, with_offset, colon, offset_position = prepare_to_str_arguments(args)

      if parameterized
        self.class.parameterize(to_str(dst, label: label, dst_label: dst_label, utc_label: utc_label, year: year, parameterized: false), with_offset)
      else
        offset_label = self.class.seconds_to_utc_offset(offset(rational: false, dst: dst, year: year), colon)
        dst_label = "" unless dst

        to_str_unparameterized(dst_label, label, offset_label, offset_position, utc_label, with_offset)
      end
    end

    private

    # :nodoc
    def format_alias(name, zone, reference)
      if zone.gsub("_", " ") == reference
        ["International Date Line West", "UTC"].include?(name) || name.include?("(US & Canada)") ? name : reference.gsub(/\/.*/, "/#{name}")
      else
        nil
      end
    end

    # :nodoc:
    def dst_offset(year, method)
      period = dst_period(year)
      period ? period.send(method) : 0
    end

    # :nodoc:
    def prepare_to_str_arguments(args)
      args = args.reverse_merge(
        label: current_alias, dst_label: " (DST)", utc_label: "GMT", year: nil, parameterized: false,
        with_offset: true, colon: true, offset_position: :begin
      ).symbolize_keys

      [:label, :dst_label, :utc_label, :year, :parameterized, :with_offset, :colon, :offset_position].map { |e| args[e] }
    end

    # :nodoc:
    def to_str_unparameterized(dst_label, label, offset_label, offset_position, utc_label, with_offset)
      if !with_offset
        format("%s%s", label, dst_label)
      elsif offset_position != :end
        format("(%s%s) %s%s", utc_label, offset_label, label, dst_label)
      else
        format("%s%s (%s%s)", label, dst_label, utc_label, offset_label)
      end
    end
  end
end

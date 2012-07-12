# encoding: utf-8
#
# This file is part of the cowtech-extensions gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Cowtech
  module Extensions
    module DateTime
      extend ActiveSupport::Concern

      module ClassMethods
        def days(short = true)
          days = Cowtech::Extensions.settings.date_names[short ? :short_days : :long_days]
          (1..7).to_a.collect { |i|
            {:value => i.to_s, :label=> days[i - 1]}
          }

        end

        def months(short = true)
          months = Cowtech::Extensions.settings.date_names[short ? :short_months : :long_months]
          (1..12).collect { |i|
            {:value => i.to_s.rjust(2, "0"), :label=> months.at(i - 1)}
          }
        end

        def years(offset = 10, also_future = true, reference = nil)
          y = (reference || Date.today).year
          (y - offset..(also_future ? y + offset : y)).collect { |year| {:value => year, :label => year} }
        end

        def easter(year = nil)
          day = 1
          month = 3
          year = Date.today.year if !year.is_integer?

          # Compute using Gauss Method
          a = year % 19
          d = ((19 * a) + 24) % 30
          e = ((2 * (year % 4)) + (4 * (year % 7)) + (6 * d) + 5) % 7

          if d + e < 10 then
            day = d + e + 22
          else
            day = d + e - 9
            month = 4
          end

          if day == 26 && month == 4 then
            day = 19
          elsif day == 25 && month == 4 && d == 28 && e == 6 && a > 10 then
            day = 18
          end
          # End

          Date.civil(year, month, day)
        end

        def custom_format(key)
          Cowtech::Extensions.settings.date_formats.fetch(key.to_sym, key).ensure_string
        end

        def is_valid?(value, format = "%F %T")
          rv = true

          format = self.custom_format(format)

          begin
            ::DateTime.strptime(value, format)
          rescue => e
            rv = false
          end

          rv
        end

        def rational_offset(tz = ::Time.zone)
          Rational((tz.tzinfo.current_period.utc_offset / 3600), 24)
        end

        def parameterize_zone(tz)
          tz = tz.to_s if !tz.is_a?(String)

          if tz =~ /^(\([a-z]+([+-])(\d{2}):(\d{2})\)\s(.+))$/i then
            "#{$2}#{$3}#{$4}@#{$5.parameterize}"
          else
            tz.parameterize
          end
        end

        def find_parameterized_zone(tz, as_string = false)
          tz = Date.parameterize_zone(tz) if !tz.is_a?(String)
          tz.gsub!(/^(.+\d{4}@)?/, "")

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

      def utc_time
        ua = (self.respond_to?(:utc) ? self : self.to_datetime).utc
        ::Time.utc(ua.year, ua.month, ua.day, ua.hour, ua.min, ua.sec)
      end

      def in_months(base = nil)
        base ||= Date.today.year
        ((self.year) - base) * 12 + self.month
      end

      def padded_month
        self.month.to_s.rjust(2, "0")
      end

      def lstrftime(format = nil)
        rv = nil
        names = Cowtech::Extensions.settings.date_names

        final_format = ::DateTime.custom_format(format).ensure_string.gsub(/(%{1,2}[abz])/i) do |match|
          mrv = match

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
              when "%Z"
                mrv = self.formatted_offset(true)  if RUBY_VERSION =~ /^1\.8/ # This is to fix ruby 1.8 bug in OSX
              when "%z"
                mrv = self.formatted_offset(false)  if RUBY_VERSION =~ /^1\.8/ # This is to fix ruby 1.8 bug in OSX
            end

            mrv.sub!("%", "%%")
          end

          mrv
        end

        self.strftime(final_format)
      end

      def local_strftime(format = nil)
        (self.respond_to?(:in_time_zone) ? self.in_time_zone : self).strftime(::DateTime.custom_format(format))
      end

      def local_lstrftime(format = nil)
        (self.respond_to?(:in_time_zone) ? self.in_time_zone : self).lstrftime(format)
      end
    end
  end
end

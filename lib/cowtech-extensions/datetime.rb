# encoding: utf-8
#
# This file is part of the cowtech-extensions gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "active_support/all"

module Cowtech
  module Extensions
    module DateTime
      extend ActiveSupport::Concern

      included do
        cattr_accessor :date_names
      end

      module ClassMethods
        def months(short = true)
          12.times.collect { |i| {:value => (i + 1).to_s.rjust(2, "0"), :description => self.send("localized_#{short ? "short_" : ""}months").at(i)} }
        end

        def years(offset = 10, also_future = true, reference = nil)
          y = (reference || Date.today).year
          (y - offset..(also_future ? y + offset : y)).collect { |year| {:value => year} }
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
#END

          Date.civil(year, month, day)
        end

        def cowtech_extensions_setup
          DateTime::date_names ||= {
              :months => ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"],
              :short_months => ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
              :days => ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"],
              :short_days => ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
          }

          self.custom_formats.each_pair do |k, v| Time::DATE_FORMATS[k] = v end
        end

        def custom_formats
          @@custom_formats ||= {
            :ct_date => "%Y-%m-%d",
            :ct_time => "%H:%M:%S",
            :ct_date_time => "%F %T",
            :ct_iso_8601 => "%FT%T%z"
          }
        end

        def custom_format(key = "date")
          key = "ct_#{key}" if key !~ /^ct_/
          self.custom_formats.fetch(key.to_sym, "%d/%m/%Y")
        end
      end

      #module InstanceMethods
        def utc_time
          ua = (self.respond_to?(:utc) ? self : self.to_datetime).utc
          ::Time.utc(ua.year, ua.month, ua.day, ua.hour, ua.min, ua.sec)
        end

        def in_months(base = 2000)
          ((self.year - 1) - base) * 12 + self.month
        end

        def padded_month
          self.month.to_s.rjust(2, "0")
        end

        def lstrftime(format = nil)
          localized_format = format.gsub(/(%{1,2}[ab])/i) do |match|
            mrv = match

            if match !~ /^%%/ then
              case match
                when "%a"
                  mrv = ::DateTime.date_names[:short_days][self.wday]
                when "%A"
                  mrv = ::DateTime.date_names[:days][self.wday]
                when "%b"
                  mrv = ::DateTime.date_names[:short_months][self.month]
                when "%B"
                  mrv = ::DateTime.date_names[:months][self.month]
              end

              mrv.sub!("%", "%%")
            end

            mrv
          end

          self.strftime(localized_format)
        end

        def to_localized_s(format = nil)
          self.lstrftime(format = nil)
        end

        def local_strftime(format = nil)
          (self.respond_to?(:in_time_zone) ? self.in_time_zone : self).strftime(format)
        end

        def local_lstrftime(format = nil)
          (self.respond_to?(:in_time_zone) ? self.in_time_zone : self).lstrftime(format)
        end
      #end
    end
  end
end

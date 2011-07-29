# encoding: utf-8
#
# This file is part of the cowtech-extensions gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "active_support"

module Cowtech
  module Extensions
    module DateTime
      extend ActiveSupport::Concern
      
      included do
        mattr_accessor :localized_months
        mattr_accessor :localized_short_months
        mattr_accessor :localized_days
        mattr_accessor :localized_short_days        
      end
      
      module ClassMethods
        def months(short = true)
          12.times.collect |k| {:value => (i + 1).to_s.rjust(2, "0"), :description => self.send("localized_#{short ? "short_" : ""}months").at(i) }
        end

        def default_localization
          @localized_months = Date.MONTHNAMES
          @localized_short_months = Date.ABBR_MONTHNAMES
          @localized_days = Date.DAYNAMES
          @localized_short_days = Date.ABBR_DAYNAMES
        end
        
        def custom_formats
          @@custom_formats ||= {
            "date" => "%d/%m/%Y",
            "time" => "%H:%M:%S",
            "date-8601" => "%Y-%m-%d",
            "date-time-8601" => "%Y-%m-%d %H:%M:%S",
            "iso-8601" => "%FT%T%z",
            "update" => "%d/%m/%Y %H:%M"
          }
        end
        
        def custom_format(key = "date")
          self.custom_formats.fetch(key.to_s, "%d/%m/%Y")
        end

        def years(offset = 10, also_future = true)
          y = Date.today.year
          (y - offset..(also_future ? y + offset : y)).collect do |year| {:value => year} end
        end

        def easter(year = nil)
          day = 1
          month = 3
          year = Date.today.year if !year.is_integer?

          # GAUSS METHOD
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
      end

      module InstanceMethods
        def lstrftime(format = nil)
          format = self.class.custom_format($1) if format =~ /^custom::(.+)/    
          unlocal = self.strftime(format || self.class.custom_format("update"))
    
          # CHANGE LONG DAYS AND MONTHS
          unlocal.gsub!(/(#{self.class.localized_months.keys.join("|")})/i) do |s| self.class.localized_months[$1] end
          unlocal.gsub!(/(#{self.class.localized_days.keys.join("|")})/i) do |s| self.class.localized_days[$1] end

          # CHANGE SHORT DAYS AND MONTHS
          unlocal.gsub!(/(#{self.class.localized_short_months.keys.join("|")})/i) do |s| self.class.localized_short_months[$1] end
          unlocal.gsub!(/(#{self.class.localized_short_days.keys.join("|")})/i) do |s| self.class.localized_short_days[$1] end

          unlocal
        end

        def local_lstrftime(format = nil)
          (self.respond_to?(:in_time_zone) ? self.in_time_zone : self).lstrftime(format)          
        end
        
        def padded_month
          self.month.to_s.rjust(2, "0") 
        end
  
        def in_months
          ((self.year - 1) % 2000) * 12 + self.month
        end
        
        def utc_time
          (self.respond_to?(:utc) ? self : self.to_datetime).utc.to_time
        end
      end
    end
  end
end
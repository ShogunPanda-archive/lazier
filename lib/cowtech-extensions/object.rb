# encoding: utf-8
#
# This file is part of the cowtech-extensions gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "active_support/all"
require "action_view"

module Cowtech
	module Extensions
		module Object
			include ActionView::Helpers::NumberHelper
			extend ActiveSupport::Concern

      def is_number?
				self.is_float?
			end

			def is_integer?
				self.is_a?(Integer) || /^([+-]?)(\d+)$/.match(self.ensure_string.strip)
			end

			def is_float?
				self.is_a?(Float) || /^([+-]?)(\d+)([.,]\d+)?$/.match(self.ensure_string.strip)
			end

			def is_boolean?
				self.is_a?(TrueClass) || self.is_a?(FalseClass) || self.is_a?(NilClass) || /^(1|0|true|false|yes|no|t|f|y|n)$/i.match(self.ensure_string.strip)
			end

			def ensure_array
				self.is_a?(Array) ? self : [self]
			end

			def ensure_string
				self.present? ? self.to_s : ""
			end

			def to_float
				self.is_float? ? Kernel.Float(self.respond_to?(:gsub) ? self.gsub(",", ".") : self) : 0.0
			end

			def to_integer
        self.is_integer? ? Kernel.Integer(self) : 0
      end

			def to_boolean
				(self.is_a?(TrueClass) || /^(1|on|true|yes|t|y)$/i.match(self.ensure_string.strip)) ? true : false
			end

			def round_to_precision(prec = 2)
				number_with_precision(self, :precision => prec)
			end

			def format_number(prec = 2, decimal_separator = ",", add_string = "", k_separator = ".")
				number_to_currency(self, {:precision => prec, :separator => decimal_separator, :delimiter => k_separator, :format => add_string.blank? ? "%n" : "%n %u", :unit => add_string.blank? ? "" : add_string.strip})
			end

			def format_boolean
        TrueClass.boolean_names[self.to_boolean.to_i]
			end

			def debug_dump(format = :yaml, must_raise = true)
				rv = ""

				begin
					if format == :pretty_json then
						rv = JSON.pretty_generate(self)
					else
						rv = self.send("to_#{format}")
					end
				rescue
					rv = self.inspect
				end

				must_raise ? raise(Cowtech::Extensions::Exceptions::Dump.new(rv)) : rv
			end
		end
	end
end
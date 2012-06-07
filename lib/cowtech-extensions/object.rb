# encoding: utf-8
#
# This file is part of the cowtech-extensions gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Cowtech
	module Extensions
		module Object
			include ActionView::Helpers::NumberHelper
			extend ActiveSupport::Concern

      def normalize_number
        rv = self.ensure_string.strip
        rv = rv.split(/[\.,]/)
        rv[-1] = "." + rv[-1] if rv.length > 1
        rv.join("")
      end

      def is_number?
				self.is_float?
			end

			def is_integer?
				self.is_a?(Integer) || /^([+-]?)(\d+)$/.match(self.normalize_number)
			end

			def is_float?
				self.is_a?(Float) || /^([+-]?)(\d+)([.,]\d+)?$/.match(self.normalize_number)
			end

			def is_boolean?
				self.is_a?(TrueClass) || self.is_a?(FalseClass) || self.is_a?(NilClass) || (self.ensure_string.strip =~ /^(1|0|true|false|yes|no|t|f|y|n)$/i)
			end

			def ensure_array
				self.is_a?(Array) ? self : [self]
			end

			def ensure_string
				self.present? ? self.to_s : ""
			end

			def to_float(default_value = 0.0)
        if self.is_a?(Float)
          self
        elsif self.is_a?(Integer)
          self.to_f
        else
				  self.is_float? ? Kernel.Float(self.normalize_number) : default_value
        end
			end

			def to_integer(default_value = 0)
        if self.is_a?(Integer)
          self
        elsif self.is_a?(Float)
          self.to_i
        else
          self.is_integer? ? Kernel.Integer(self.normalize_number) : default_value
        end
      end

			def to_boolean
        rv = self
        rv = rv.to_i if rv.is_a?(Float)
				(rv.is_a?(TrueClass) || /^(1|on|true|yes|t|y)$/i.match(rv.ensure_string.strip)) ? true : false
			end

			def round_to_precision(prec = 2)
        (self.is_number? && prec >= 0) ? number_with_precision(self, :precision => prec) : nil
			end

			def format_number(prec = nil, decimal_separator = nil, add_string = nil, k_separator = nil)
        prec = Cowtech::Extensions.settings.format_number[:prec] if prec.nil?
        decimal_separator = Cowtech::Extensions.settings.format_number[:decimal_separator] if decimal_separator.nil?
        add_string = Cowtech::Extensions.settings.format_number[:add_string] if add_string.nil?
        k_separator = Cowtech::Extensions.settings.format_number[:k_separator] if k_separator.nil?

        (self.is_number? && prec >= 0) ? number_to_currency(self, {:precision => prec, :separator => decimal_separator, :delimiter => k_separator, :format => add_string.blank? ? "%n" : "%n %u", :unit => add_string.blank? ? "" : add_string.strip}) : nil
			end

      def set_defaults_for_format_number

      end

			def format_boolean
        Cowtech::Extensions.settings.boolean_names[self.to_boolean]
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
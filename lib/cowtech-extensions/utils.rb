# encoding: utf-8
#
# This file is part of the cowtech-extensions gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Cowtech
	module Extensions
    class Settings
      attr_reader :format_number, :date_names, :boolean_names

      def self.instance
        @@instance ||= Cowtech::Extensions::Settings.new
      end

      def initialize
        self.setup_format_number
        self.setup_boolean_names
      end

      def setup_format_number(prec = 2, decimal_separator = ".", add_string = "", k_separator = ",")
        @format_number = {
          :prec => prec,
          :decimal_separator => decimal_separator,
          :add_string => add_string,
          :k_separator => k_separator
        }
      end

      def setup_boolean_names(true_name = "Yes", false_name = "No")
        @boolean_names = {true => true_name, false => false_name}
      end
    end

		module Exceptions
			class Dump < ::RuntimeError
			end
		end
	end
end

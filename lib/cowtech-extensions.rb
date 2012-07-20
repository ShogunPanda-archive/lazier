# encoding: utf-8
#
# This file is part of the cowtech-extensions gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

$KCODE='UTF8' if RUBY_VERSION < '1.9'

require "json"
require "tzinfo"
require "active_support/all"
require "action_view"

require "cowtech-extensions/exceptions"
require "cowtech-extensions/settings"
require "cowtech-extensions/object"
require "cowtech-extensions/boolean"
require "cowtech-extensions/string"
require "cowtech-extensions/hash"
require "cowtech-extensions/datetime"
require "cowtech-extensions/math"
require "cowtech-extensions/pathname"

# This is the top level module for Cowtech libraries.
module Cowtech
  # Several Ruby object enhancements.
	module Extensions
    # Checks if we are running under Ruby 1.8
    #
    # @return [Boolean] `true` for Ruby 1.8, `false` otherwise.
    def self.is_ruby_18?
      RUBY_VERSION =~ /^1\.8/
    end

    # Returns the settings for the extensions
    #
    # @return [Settings] The settings for the extensions.
    def self.settings
      ::Cowtech::Extensions::Settings.instance
    end

    # Loads the extensions.
    #
    # @param what [Array] The modules to load. Valid values are:
    #   @option object Extensions for all objects.
    #   @option boolean Extensions for boolean values.
    #   @option string Extensions for strings.
    #   @option hash Extensions for hashs.
    #   @option datetime Extensions date and time objects.
    #   @option math Extensions for Math module.
    #   @option pathname Extensions for path objects.
    # @return [Settings] The settings for the extensions.
		def self.load!(*what)
			what = ["object", "boolean", "string", "hash", "datetime", "math", "pathname"] if what.count == 0
			what.collect! { |w| w.to_s }

      # Dependency resolving
      what << "object" if what.include?("datetime")
      what << "object" if what.include?("math")
      what.compact.uniq!

			if what.include?("object") then
				::Object.class_eval do
					include ::Cowtech::Extensions::Object
				end
			end

			if what.include?("boolean") then
				::TrueClass.class_eval do
					include ::Cowtech::Extensions::Object
					include ::Cowtech::Extensions::Boolean
        end

				::FalseClass.class_eval do
          include ::Cowtech::Extensions::Object
          include ::Cowtech::Extensions::Boolean
				end
      end

			if what.include?("string") then
				::String.class_eval do
					include ::Cowtech::Extensions::String
				end
			end

			if what.include?("hash") then
				::Hash.class_eval do
					include ::Cowtech::Extensions::Hash
				end
			end

			if what.include?("datetime") then
				::Time.class_eval do
					include ::Cowtech::Extensions::DateTime
				end

				::Date.class_eval do
					include ::Cowtech::Extensions::DateTime
				end

				::DateTime.class_eval do
					include ::Cowtech::Extensions::DateTime
        end

        ::ActiveSupport::TimeZone.class_eval do
          include ::Cowtech::Extensions::TimeZone
        end
			end

			if what.include?("math") then
				::Math.class_eval do
					include ::Cowtech::Extensions::Math
				end
			end

			if what.include?("pathname") then
				require "pathname"

				::Pathname.class_eval do
					include ::Cowtech::Extensions::Pathname
				end
      end

      yield if block_given?

      ::Cowtech::Extensions::Settings.instance
		end
	end
end
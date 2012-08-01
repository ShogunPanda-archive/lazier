# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2012 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

$KCODE='UTF8' if RUBY_VERSION < '1.9'

require "json"
require "tzinfo"
require "active_support/all"
require "action_view"

require "lazier/version" if !defined?(Lazier::Version)
require "lazier/exceptions"
require "lazier/settings"
require "lazier/object"
require "lazier/boolean"
require "lazier/string"
require "lazier/hash"
require "lazier/datetime"
require "lazier/math"
require "lazier/pathname"

# Several Ruby object enhancements.
module Lazier
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
    ::Lazier::Settings.instance
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
        include ::Lazier::Object
      end
    end

    if what.include?("boolean") then
      ::TrueClass.class_eval do
        include ::Lazier::Object
        include ::Lazier::Boolean
      end

      ::FalseClass.class_eval do
        include ::Lazier::Object
        include ::Lazier::Boolean
      end
    end

    if what.include?("string") then
      ::String.class_eval do
        include ::Lazier::String
      end
    end

    if what.include?("hash") then
      ::Hash.class_eval do
        include ::Lazier::Hash
      end
    end

    if what.include?("datetime") then
      ::Time.class_eval do
        include ::Lazier::DateTime
      end

      ::Date.class_eval do
        include ::Lazier::DateTime
      end

      ::DateTime.class_eval do
        include ::Lazier::DateTime
      end

      ::ActiveSupport::TimeZone.class_eval do
        include ::Lazier::TimeZone
      end
    end

    if what.include?("math") then
      ::Math.class_eval do
        include ::Lazier::Math
      end
    end

    if what.include?("pathname") then
      require "pathname"

      ::Pathname.class_eval do
        include ::Lazier::Pathname
      end
    end

    yield if block_given?

    ::Lazier::Settings.instance
  end
end

# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "json"
require "tzinfo"
require "active_support/all"
require "action_view"
require "r18n-desktop"

require "lazier/version" if !defined?(Lazier::Version)
require "lazier/exceptions"
require "lazier/i18n"
require "lazier/localizer"
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
  # Returns the settings for the extensions.
  #
  # @return [Settings] The settings for the extensions.
  def self.settings
    ::Lazier::Settings.instance
  end

  # Loads the extensions.
  #
  # @param what [Array] The modules to load. Valid values are:
  #
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
    what.collect! { |w| ::Lazier.send("load_#{w}") }

    yield if block_given?
    ::Lazier::Settings.instance
  end

  # Loads Object extensions.
  def self.load_object
    ::Object.class_eval do
      include ::Lazier::Object
    end
  end

  # Loads Boolean extensions.
  def self.load_boolean
    ::TrueClass.class_eval do
      include ::Lazier::Object
      include ::Lazier::Boolean
    end

    ::FalseClass.class_eval do
      include ::Lazier::Object
      include ::Lazier::Boolean
    end
  end

  # Loads String extensions.
  def self.load_string
    ::String.class_eval do
      include ::Lazier::String
    end
  end

  # Loads Hash extensions.
  def self.load_hash
    ::Hash.class_eval do
      include ::Lazier::Hash
    end
  end

  # Loads DateTime extensions.
  def self.load_datetime
    Lazier.load_object

    [::Time, ::Date, ::DateTime].each do |c|
      c.class_eval do
        include ::Lazier::DateTime
      end
    end

    ::ActiveSupport::TimeZone.class_eval do
      include ::Lazier::TimeZone
    end
  end

  # Loads Math extensions.
  def self.load_math
    Lazier.load_object

    ::Math.class_eval do
      include ::Lazier::Math
    end
  end

  # Loads Pathname extensions.
  def self.load_pathname
    require "pathname"

    ::Pathname.class_eval do
      include ::Lazier::Pathname
    end
  end
end

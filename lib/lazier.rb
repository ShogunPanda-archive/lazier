# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun_panda@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "json"
require "tzinfo"
require "active_support/all"
require "action_view"
require "r18n-desktop"
require "hashie"

require "lazier/version" if !defined?(Lazier::Version)
require "lazier/exceptions"
require "lazier/i18n"
require "lazier/localizer"
require "lazier/configuration"
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
    (what.present? ? what : ["object", "boolean", "string", "hash", "datetime", "math", "pathname"]).each { |w| ::Lazier.send("load_#{w}") }
    yield if block_given?
    ::Lazier::Settings.instance
  end

  # Loads Object extensions.
  def self.load_object
    ::Object.class_eval { include ::Lazier::Object }
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
    ::String.class_eval { include ::Lazier::String }
  end

  # Loads Hash extensions.
  def self.load_hash
    ::Hash.class_eval do
      include Hashie::Extensions::MethodAccess
      include ::Lazier::Hash
    end
  end

  # Loads DateTime extensions.
  def self.load_datetime
    Lazier.load_object

    [::Time, ::Date, ::DateTime].each do |c|
      c.class_eval { include ::Lazier::DateTime }
    end

    ::ActiveSupport::TimeZone.class_eval { include ::Lazier::TimeZone }
  end

  # Loads Math extensions.
  def self.load_math
    Lazier.load_object
    ::Math.class_eval { include ::Lazier::Math }
  end

  # Loads Pathname extensions.
  def self.load_pathname
    require "pathname"
    ::Pathname.class_eval { include ::Lazier::Pathname }
  end

  # Finds a class to instantiate.
  #
  # @param cls [Symbol|String|Object] If a `String` or a `Symbol` or a `Class`, then it will be the class to instantiate. Otherwise the class of the object will returned.
  # @param scope [String] An additional scope to find the class. `%CLASS%` will be substituted with the class name.
  # @param only_in_scope [Boolean] If only try to instantiate the class in the scope.
  # @return [Class] The found class.
  def self.find_class(cls, scope = "::%CLASS%", only_in_scope = false)
    if cls.is_a?(::String) || cls.is_a?(::Symbol) then
      rv = nil
      cls = cls.to_s.camelize

      if only_in_scope then
        cls.gsub!(/^::/, "") # Mark only search only inside scope
      else
        rv = search_class(cls) # Search outside scope
      end

      rv = search_class(scope.to_s.gsub("%CLASS%", cls)) if !rv && cls !~ /^::/ && scope.present? # Search inside scope
      rv || raise(NameError.new("", cls))
    else
      cls.is_a?(::Class) ? cls : cls.class
    end
  end

  private
    # Tries to search a class.
    #
    # @param cls [String] The class to search.
    # @return [Class] The instantiated class or `nil`, if the class was not found.
    def self.search_class(cls)
      cls.constantize rescue nil
    end
end

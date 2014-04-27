# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "json"
require "tzinfo"
require "active_support/core_ext"
require "r18n-desktop"
require "hashie"

require "lazier/version" unless defined?(Lazier::Version)
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
  #   @option hash_method_access Extensions for hash to allow method access. Not included by default.
  #   @option datetime Extensions date and time objects.
  #   @option math Extensions for Math module.
  #   @option pathname Extensions for path objects.
  # @return [Settings] The settings for the extensions.
  def self.load!(*what)
    modules = what.present? ? what.flatten.uniq.compact.map(&:to_s) : %w(object boolean string hash datetime math pathname)
    modules.each { |w| ::Lazier.send("load_#{w}") }

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
    clean_hash_compact
    ::Hash.class_eval { include ::Lazier::Hash }
  end

  # Loads Hash method access extensions.
  def self.load_hash_method_access
    ::Hash.class_eval { include Hashie::Extensions::MethodAccess }
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
  # @param cls [Symbol|String|Object] If a `String` or a `Symbol` or a `Class`, then it will be the class to instantiate.
  #   Otherwise the class of the object will returned.
  # @param scope [String] An additional scope to find the class. `%CLASS%`, `%`, `$`, `?` and `@` will be substituted with the class name.
  # @param only_in_scope [Boolean] If only try to instantiate the class in the scope.
  # @return [Class] The found class.
  def self.find_class(cls, scope = "::%CLASS%", only_in_scope = false)
    if cls.is_a?(::String) || cls.is_a?(::Symbol)
      rv, cls = perform_initial_class_search(cls, only_in_scope)
      rv = search_class_inside_scope(rv, cls, scope) # Search inside scope
      rv || raise(NameError.new("", cls))
    else
      cls.is_a?(::Class) ? cls : cls.class
    end
  end

  # Measure the time in milliseconds required to execute the given block.
  #
  # @param message [String|NilClass] An optional message (see return value).
  # @param precision [Fixnum] The precision for the message (see return value)..
  # @param block [Proc] The block to evaluate.
  # @return [Float|String] If a `message` is provided, then the message itself plus the duration under parenthesis will be returned,
  #   otherwise the duration alone as a number.
  def self.benchmark(message = nil, precision = 0, &block)
    rv = Benchmark.ms(&block)
    message ? format("%s (%0.#{precision}f ms)", message, rv) : rv
  end

  private

  # Removes existing `compact` and `compact!` methods from the Hash class.
  def self.clean_hash_compact
    ::Hash.class_eval do
      begin
        remove_method(:compact)
        remove_method(:compact!)
      rescue
        nil
      end
    end
  end

  # Performs the initial search to find a class.
  # @param cls [Symbol|String|Object] If a `String` or a `Symbol` or a `Class`, then it will be the class to instantiate.
  # @param only_in_scope [Boolean] If only try to instantiate the class in the scope.
  # @return [Array] The found class (if any) and the sanitized name.
  def self.perform_initial_class_search(cls, only_in_scope)
    rv = nil
    cls.to_s.camelize

    if only_in_scope
      cls.gsub!(/^::/, "") # Mark only search only inside scope
    else
      rv = search_class(cls) # Search outside scope
    end

    [rv, cls]
  end

  # Tries to search a class.
  #
  # @param cls [String] The class to search.
  # @return [Class] The instantiated class.
  def self.search_class(cls)
    cls.constantize rescue nil
  end

  # Finds a class inside a specific scope.
  #
  # @param current [Class] The class found outside the scope.
  # @param cls [String] The class to search.
  # @param scope [String] The scope to search the class into.
  # @return [Class] The found class.
  def self.search_class_inside_scope(current, cls, scope)
    cls = cls.ensure_string
    !current && cls !~ /^::/ && scope.present? ? search_class(scope.to_s.gsub(/%CLASS%|[@%$?]/, cls)) : current
  end
end

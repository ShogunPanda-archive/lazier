#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require(RUBY_ENGINE != "jruby" ? "oj" : "json")
require "English"
require "tzinfo"
require "active_support"
require "active_support/core_ext"
require "i18n"
require "i18n/backend/fallbacks"
require "hashie"
require "pathname"

I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
require "lazier/version" unless defined?(Lazier::Version)
require "lazier/exceptions"
require "lazier/i18n"
require "lazier/configuration"
require "lazier/settings"
require "lazier/object"
require "lazier/boolean"
require "lazier/string"
require "lazier/hash"
require "lazier/datetime"
require "lazier/timezone"
require "lazier/math"
require "lazier/pathname"

# Several Ruby object enhancements.
module Lazier
  # The root directory of the library
  ROOT = File.absolute_path(__dir__ + "/../")

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
    valid_modules = [:object, :boolean, :string, :hash, :datetime, :math, :pathname]
    modules = what.present? ? what.flatten.uniq.compact.map(&:to_sym) : valid_modules
    (modules & valid_modules).each { |w| ::Lazier.send("load_#{w}") }

    yield if block_given?
    ::Lazier::Settings.instance
  end

  # Loads Object extensions.
  def self.load_object
    Lazier.load_boolean
    perform_load(:object, ::Object, ::Lazier::Object)
  end

  # Loads Boolean extensions.
  def self.load_boolean
    perform_load(:boolean) do
      [::TrueClass, ::FalseClass].each do |klass|
        klass.class_eval do
          include ::Lazier::Object
          include ::Lazier::Boolean
        end
      end
    end
  end

  # Loads String extensions.
  def self.load_string
    perform_load(:string, ::String, ::Lazier::String)
  end

  # Loads Hash extensions.
  def self.load_hash
    Lazier.load_object

    perform_load(:hash) do
      clean_hash_compact
      ::Hash.class_eval { include ::Lazier::Hash }
    end
  end

  # Loads DateTime extensions.
  def self.load_datetime
    Lazier.load_object

    perform_load(:datetime) do
      [::Time, ::Date, ::DateTime].each do |c|
        c.class_eval { include ::Lazier::DateTime }
      end

      ::ActiveSupport::TimeZone.class_eval { include ::Lazier::TimeZone }
    end
  end

  # Loads Math extensions.
  def self.load_math
    Lazier.load_object
    perform_load(:math, ::Math, ::Lazier::Math)
  end

  # Loads Pathname extensions.
  def self.load_pathname
    perform_load(:pathname, ::Pathname, ::Lazier::Pathname)
  end

  # Finds a class to instantiate.
  #
  # @param cls [Symbol|String|Object] If a `String` or a `Symbol` or a `Class`, then it will be the class to instantiate.
  #   Otherwise the class of the object will returned.
  # @param scope [String] The scope where to find the class. `%CLASS%`, `%`, `$`, `?` and `@` will be substituted with the class name.
  # @param only_in_scope [Boolean] If only search inside the scope.
  # @return [Class] The found class.
  def self.find_class(cls, scope = "::@", only_in_scope = false)
    if [::String, ::Symbol].include?(cls.class)
      cls = cls.to_s.camelize
      cls.gsub!(/^::/, "") if scope && only_in_scope
      search_class(cls, scope) || raise(NameError, ["", cls])
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
  def self.benchmark(message: nil, precision: 0, &block)
    rv = Benchmark.ms(&block)
    message ? format("%s (%0.#{precision}f ms)", message, rv) : rv
  end

  # Returns which platform are we running on. Can be `:java`, `:osx`, `:posix` or `:win32`
  #
  # @return [Boolean] If force detection again.
  # @return [Symbol] The current platform.
  def self.platform(force = false)
    @platform = nil if force

    @platform ||=
      case RUBY_PLATFORM
      when /cygwin|mingw|win32/ then :win32
      when /java/ then :java
      when /darwin/ then :osx
      else :posix
      end
  end

  private

  # :nodoc:
  def self.clean_hash_compact
    ::Hash.class_eval do
      remove_method(:compact) if {}.respond_to?(:compact)
      remove_method(:compact!) if {}.respond_to?(:compact!)
    end
  end

  # :nodoc:
  def self.search_class(cls, scope = nil)
    cls = scope.gsub(/%CLASS%|[@%$?]/, cls)
    cls.constantize
  rescue
    nil
  end

  # :nodoc:
  # TODO@PI: On 4.1, make loaded accessible publicly and add a Lazier.loaded? method.
  def self.perform_load(mod, target = nil, extension = nil, &block)
    @loaded ||= []

    unless @loaded.include?(mod)
      block_given? ? block.call : target.class_eval { include extension }
      @loaded << mod
    end
  end
end

#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Lazier
  # A configuration class to set properties.
  class Configuration < Hashie::Dash
    # Initializes a new configuration object.
    # @see Hash#initialize
    #
    # @param attributes [Hash] The initial values of properties of this configuration.
    # @param block [Proc] A block to use for default values.
    def initialize(attributes = {}, &block)
      @i18n = Lazier::I18n.instance
      super(attributes, &block)
    end

    # Defines a property on the configuration.

    # @param name [String|Symbol] The new property name.
    # @param options [Hash] The options for the property.
    # @option options [Boolean] :default Specify a default value for this property.
    # @option options [Boolean] :required Specify the value as required for this property, to raise an error if a value is unset in a new or existing configuration.
    # @option options [Boolean] :readonly Specify if the property is readonly, which means that it can only defined during creation of the configuration.
    def self.property(name, options = {})
      super(name, options)

      if options[:readonly]
        send(:define_method, "#{name}=") do |_|
          assert_readonly_property!(name)
        end
      end
    end

    private

    # :nodoc:
    def assert_readonly_property!(name)
      raise(ArgumentError, assertion_error("configuration.readonly", name))
    end

    # :nodoc:
    def assert_property_exists!(name)
      raise(ArgumentError, assertion_error("configuration.not_found", name)) unless self.class.property?(name)
    end

    # :nodoc:
    def assert_property_set!(name)
      raise(ArgumentError, assertion_error("configuration.required", name)) if send(name).nil?
    end

    # :nodoc:
    def assert_property_required!(name, value)
      raise(ArgumentError, assertion_error("configuration.required", name)) if value.nil? && self.class.required?(name)
    end

    # :nodoc:
    def assertion_error(label, name)
      @i18n.translate(label, name: name, class: self.class.name)
    end
  end
end

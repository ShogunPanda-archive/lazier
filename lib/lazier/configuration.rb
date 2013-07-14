# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Lazier
  # A configuration class to set properties.
  class Configuration < Hashie::Dash
    include ::Lazier::I18n

    # Initializes a new configuration object.
    #
    # @param attributes [Hash] The initial values of properties of this configuration.
    def initialize(attributes = {}, &block)
      i18n_setup(:lazier, ::File.absolute_path(::Pathname.new(::File.dirname(__FILE__)).to_s + "/../../locales/"))
      super(attributes, &block)
    end

    # Defines a property on the configuration.
    # Options are as follows:
    #
    # * :default - Specify a default value for this property.
    # * :required - Specify the value as required for this property, to raise an error if a value is unset in a new or existing configuration.
    # * :readonly - Specify if the property is readonly, which means that it can only defined during creation of the configuration.
    #
    # @param property_name [String|Symbol] The new property name.
    # @param options [Hash] The options for the property.
    def self.property(property_name, options = {})
      super(property_name, options)

      if options[:readonly] then
        class_eval <<-ACCESSOR
          def #{property_name}=(_)
            raise ArgumentError.new(i18n.configuration.readonly("#{property_name}", "#{name}"))
          end
        ACCESSOR
      end
    end

    private
      # Checks if a property exists.
      #
      # @param property [String|Symbol] The property to check.
      def assert_property_exists!(property)
        raise ArgumentError.new(i18n.configuration.not_found(property, self.class.name)) if !self.class.property?(property)
      end

      # Checks if a property has been set.
      #
      # @param property [String|Symbol] The property to check.
      def assert_property_set!(property)
        raise ArgumentError.new(i18n.configuration.required(property, self.class.name)) if send(property).nil?
      end

      # Checks if a property is required.
      #
      # @param property [String|Symbol] The property to check.
      def assert_property_required!(property, value)
        raise ArgumentError.new(i18n.configuration.required(property, self.class.name)) if self.class.required?(property) && value.nil?
      end
  end
end
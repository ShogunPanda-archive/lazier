# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Lazier
  # Provides an easy way to localized messages in a class.
  #
  # @attribute [r] i18n_locale
  #   @return [String|Symbol|nil] The current locale.
  # @attribute [r] i18n_root
  #   @return [Symbol] The root level of the translation.
  # @attribute [r] i18n_locales_path
  #   @return [String] The path where the translations are stored.
  module I18n
    attr_reader :i18n_locale
    attr_reader :i18n_root
    attr_reader :i18n_locales_path

    # Setup all I18n translations.
    #
    # @param root [Symbol] The root level of the translation.
    # @param path [String] The path where the translations are stored.
    def i18n_setup(root, path)
      ::I18n.enforce_available_locales = true
      @i18n_root = root.to_sym
      @i18n_locales_path = path
    end

    # Get the list of available translation for the current locale.
    #
    # @return [R18N::Translation] The translation object.
    def i18n
      @i18n ||= i18n_load_locale(nil)
    end

    # Set the current locale for messages.
    #
    # @param locale [String|Symbol|nil] The new locale. Default is the current system locale.
    # @return [R18n::Translation] The new translation object.
    def i18n=(locale)
      @i18n_locale = locale
      @i18n = i18n_load_locale(locale)
    end

    private
      # Loads a locale for messages.
      #
      # @param locale [Symbol] The new locale. Default is the current system locale.
      # @return [R18n::Translation] The new translation object.
      def i18n_load_locale(locale)
        path = @i18n_locales_path || ""
        locales = validate_locales([locale], path)

        begin
          tokens = @i18n_root.to_s.split(/[:.]/)
          translation = tokens.reduce(R18n::I18n.new(locales, path).t) {|accu, token| accu.send(token) }
          raise ArgumentError if translation.is_a?(R18n::Untranslated)
          translation
        rescue
          raise Lazier::Exceptions::MissingTranslation.new(locales, path)
        end
      end

      # Validates locales for messages.
      #
      # @param locales [Array] The list of locales to validate. English is added as fallback.
      # @param path [String] The path where look into.
      # @return [Array] The list of valid locales.
      def validate_locales(locales, path)
        (locales + [ENV["LANG"], R18n::I18n.system_locale, "en"]).select { |l| find_locale_in_path(l, path)}.uniq.map(&:to_s)
      end

      # Find a locale file in a path.
      #
      # @param locale [String] The locale to find.
      # @param path [String] The path where look into.
      # @return [String|nil] The version of the locale found or `nil`, if nothing was found.
      def find_locale_in_path(locale, path)
        locale ? [locale, locale[0, 5], locale[0, 2]].select {|l| File.exists?("#{path}/#{l}.yml") }.first : nil
      end
  end
end
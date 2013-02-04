# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Lazier
  # Provides an easy way to localized messages in a class.
  module I18n
    # Setup all I18n translations.
    #
    # @param root [Symbol] The root level of translation.
    # @param path [String] The path where the translation are stored.
    def i18n_setup(root, path)
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
    # @param locale [String] The new locale. Default is the current system locale.
    # @return [R18n::Translation] The new translation object.
    def i18n=(locale)
      @i18n = i18n_load_locale(locale)
    end

    private
      # Loads a locale for messages.
      #
      # @param locale [Symbol] The new locale. Default is the current system locale.
      # @return [R18n::Translation] The new translation object.
      def i18n_load_locale(locale)
        path = (@i18n_locales_path || "").to_s
        locales = [locale, (ENV["LANG"] || :en), R18n::I18n.system_locale].select { |l| File.exists?("#{path}/#{l}.yml") }.uniq.compact

        p [path, locales, [locale, (ENV["LANG"] || :en), R18n::I18n.system_locale], Dir.glob(path).to_a]
        begin
          raise Lazier::Exceptions::MissingTranslation if locales.blank?
          translation = R18n::I18n.new(locales, path)
          raise Lazier::Exceptions::MissingTranslation if !translation
          translation.t.send((@i18n_root || "").to_s)
        rescue Lazier::Exceptions::MissingTranslation => e
          raise e
        end
      end
  end
end
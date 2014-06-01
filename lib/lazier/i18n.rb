#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Lazier
  # Provides an easy way to localized messages in a class.
  #
  # @attribute locale
  #   @return [String|Symbol|nil] The current locale.
  # @attribute [r] root
  #   @return [Symbol] The root level of the translation.
  # @attribute [r] path
  #   @return [String] The path where the translations are stored.
  # @attribute [r] backend
  #   @return [I18n::Backend] The backend used for translations.
  class I18n
    attr_accessor :locale
    attr_reader :root, :path, :backend

    # The default locale for new instances.
    mattr_accessor :default_locale

    # Returns the singleton instance of the settings.
    #
    # @param locale [Symbol] The locale to use for translations. Default is the current system locale.
    # @param root [Symbol] The root level of the translation.
    # @param path [String] The path where the translations are stored.
    # @param force [Boolean] If to force recreation of the instance.
    # @return [I18n] The singleton instance of the i18n.
    def self.instance(locale = nil, root: :lazier, path: nil, force: false)
      @instance = nil if force
      @instance ||= new(locale, root: root, path: path)
    end

    # Creates a new I18n object.
    #
    # @param locale [Symbol] The locale to use. Defaults to the current locale.
    # @param root [Symbol] The root level of the translation.
    # @param path [String] The path where the translations are stored.
    def initialize(locale = nil, root: :lazier, path: nil)
      path ||= Lazier::ROOT + "/locales"
      @root = root.to_sym
      @path = File.absolute_path(path.to_s)

      setup_backend

      self.locale = (locale || Lazier::I18n.default_locale || system_locale).to_sym
    end

    # Reloads all the I18n translations.
    def reload
      # Extract the backend to an attribute
      ::I18n.backend.load_translations
    end

    # Gets the list of available translation for a locale.
    #
    # @param locale [Symbol] The locale to list. Defaults to the current locale.
    # @return [Hash] The available translations for the specified locale.
    def translations(locale = nil)
      locale ||= @locale
      @backend.send(:translations)[locale.to_sym] || {}
    end

    # Sets the current locale.
    #
    # @param value [Symbol] The locale to use for translations. Default is the current system locale.
    def locale=(value)
      @locale = value.to_sym
      ::I18n.locale = @locale
    end

    # Get the list of available translation for a locale.
    #
    # @return [Array] The list of available locales.
    def locales
      ::I18n.available_locales
    end

    # Localize a message.
    #
    # @param message [String|Symbol] The message to localize.
    # @param args [Array] Optional arguments to localize the message.
    # @return [String] The localized message.
    def translate(message, **args)
      # PI: Ignore reek on this.
      message = "#{root}.#{message}" if message !~ /^(\.|::)/

      begin
        ::I18n.translate(message, **(args.merge(raise: true)))
      rescue ::I18n::MissingTranslationData
        raise Lazier::Exceptions::MissingTranslation, [locale, message]
      end
    end
    alias_method :t, :translate

    # Localize a message in a specific locale.
    #
    # @param message [String|Symbol] The message to localize.
    # @param locale [String|Symbol] The new locale to use for localization.
    # @param args [Array] Optional arguments to localize the message.
    # @return [String] The localized message.
    def translate_in_locale(locale, message, *args)
      with_locale(locale) { translate(message, *args) }
    end
    alias_method :tl, :translate_in_locale

    # Temporary sets a different locale and execute the given block.
    #
    # @param locale [String|Symbol] The new locale to use for localization.
    def with_locale(locale)
      old_locale = self.locale

      begin
        self.locale = locale
        return yield
      ensure
        self.locale = old_locale
      end
    end

    private

    # :nodoc:
    OSX_DETECTION = "defaults read .GlobalPreferences AppleLanguages | awk 'NR==2{gsub(/[ ,]/, \"\");print}'"

    # :nodoc:
    def system_locale
      platform = Lazier.platform

      if [:java, :osx, :posix].include?(platform)
        send("system_locale_#{Lazier.platform}")
      else
        raise(RuntimeError)
      end
    rescue
      "en"
    end

    # :nodoc:
    def system_locale_java
      Java.java.util.Locale.getDefault.toString
    end

    # :nodoc:
    def system_locale_osx
      `#{OSX_DETECTION}`.strip
    end

    # :nodoc:
    def system_locale_posix
      ENV["LANG"]
    end

    # :nodoc:
    def setup_backend
      ::I18n.enforce_available_locales = true
      ::I18n.load_path += Dir["#{@path}/*.yml"]
      ::I18n.load_path.uniq!
      ::I18n.exception_handler = ::Lazier::Exceptions::TranslationExceptionHandler.new
      reload

      @backend = ::I18n.backend
    end
  end
end

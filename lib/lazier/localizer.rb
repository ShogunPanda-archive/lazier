# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun_panda@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Lazier
# A utility class to localize messages
  class Localizer
    include Lazier::I18n

    # Initialize a new localizer.
    #
    # @param root [Symbol] The root level of the translation.
    # @param path [String] The path where the translations are stored.
    # @param locale [String|Symbol] The locale to use for localization.
    def initialize(root = nil, path = nil, locale = nil)
      i18n_setup(root || :lazier, path || ::File.absolute_path(::Pathname.new(::File.dirname(__FILE__)).to_s + "/../../locales/"))
      self.i18n = locale
    end

    # Localize a message.
    #
    # @param message [String|Symbol] The message to localize.
    # @param args [Array] Optional arguments to localize the message.
    # @return [String|R18n::Untranslated] The localized message.
    def self.localize(message, *args)
      new.i18n.send(message, *args)
    end

    # Localize a message in a specified locale.
    #
    # @param locale [String|Symbol] The locale to use for localization.
    # @param message [String|Symbol] The message to localize.
    # @param args [Array] Optional arguments to localize the message.
    # @return [String|R18n::Untranslated] The localized message.
    def self.localize_on_locale(locale, message, *args)
      new(nil, nil, locale).i18n.send(message, *args)
    end
  end
end

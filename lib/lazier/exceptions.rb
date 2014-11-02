#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Lazier
  # Exceptions for lazier.
  module Exceptions
    # This exception is raised to debug code.
    class Debug < ::RuntimeError
    end

    # This is the handler for the core I18n gem.
    class TranslationExceptionHandler < ::I18n::ExceptionHandler
      # :nodoc:
      def call(exception, locale, key, options)
        exception.is_a?(::I18n::MissingTranslation) ? raise(exception.to_exception) : super
      end
    end

    # This exception is raised from {I18n I18n} if a string is not translatable.
    class MissingTranslation < RuntimeError
      # Creates a new missing translation exception.
      #
      # @param locale [Array] The locale that was requested to use.
      # @param message [String|NilClass] The message that was requested to translate.
      def initialize(locale, message = nil)
        locale, message = locale if message.nil?
        super("Unable to load the translation \"#{message}\" for the locale \"#{locale}\".")
      end
    end
  end
end

# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Lazier
  # Exceptions for lazier.
  module Exceptions
    # This exception is raised to debug code.
    class Debug < ::RuntimeError
    end

    # This exception is raised from {I18n I18n} if no valid translation are found in the specified path.
    class MissingTranslation < RuntimeError
      # Creates a new missing translation exception.
      #
      # @param locales [Array] The locales that was requested to load.
      # @param path [String] The path where was request to search for translations.
      def initialize(locales, path)
        super("Unable to load any of the following translation in #{path}: #{locales.join(", ")}.")
      end
    end
  end
end

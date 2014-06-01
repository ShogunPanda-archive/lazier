#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Lazier
  # Extensions for the String class.
  module String
    extend ::ActiveSupport::Concern

    # Makes sure the string only contains valid UTF-8 sequences.
    #
    # @param replacement [String] The string to use to replace invalid sequences.
    # @return [String] The string with any invalid UTF-8 sequences replaced.
    def ensure_valid_utf8(replacement = "")
      # This odd line is because if need to specify a different encoding (without losing infos) to replace invalid bytes and then we go back to utf-8
      encode("utf-16", invalid: :replace, undef: :replace, replace: replacement).encode("utf-8")
    end

    # Returns the string itself for use in form helpers.
    #
    # @return [String] The string itself.
    def value
      self
    end

    # Splits a string containing tokens using a specified pattern and applying some sanitizations.
    #
    # @param no_blanks [Boolean] If filter out blank tokens.
    # @param strip [Boolean] If strip single tokens.
    # @param no_duplicates [Boolean] If return uniques elements.
    # @param pattern [String|Regexp] The pattern to use.
    # @param presence_method [Symbol] The method to use to check if a token is present or not.
    # @return [Array] An array of tokens.
    def tokenize(no_blanks: true, strip: true, no_duplicates: false, pattern: /\s*,\s*/, presence_method: :present?)
      rv = split(pattern)
      rv.map!(&:strip) if strip
      rv.select!(&presence_method) if no_blanks
      rv.uniq! if no_duplicates
      rv
    end

    # Removes accents from the string, normalizing to the normal letter.
    #
    # ```ruby
    # "èòàù".remove_accents
    # # => "eoau"
    # ```
    #
    # @return The string with all accents removed.
    def remove_accents
      ::I18n.transliterate(self)
    end
  end
end

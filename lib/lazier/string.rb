# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Lazier
  # Extensions for the String class.
  module String
    extend ::ActiveSupport::Concern

    # Removes accents from the string, normalizing to the normal letter.
    #
    # ```ruby
    # "èòàù".remove_accents
    # # => "eoau"
    # ```
    #
    # @return The string with all accents removed.
    def remove_accents
      silence_warnings { mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n, "").to_s }
    end

    # Makes sure the string only contains valid UTF-8 sequences.
    #
    # @param replacement [String] The string to use to replace invalid sequences.
    # @return [String] The string with any invalid UTF-8 sequences replaced.
    def ensure_valid_utf8(replacement = "")
      # This odd line is because if need to specify a different encoding (without losing infos) to replace invalid bytes and then we go back to utf-8
      !defined?(JRUBY_VERSION) ? encode("utf-16", invalid: :replace, undef: :replace, replace: replacement).encode("utf-8") : raise(RuntimeError.new("Sorry, Lazier::String#ensure_valid_utf8 is not available on JRuby."))
    end

    # Returns the tagged version of a string.
    #
    # The string is downcased and spaces are substituted with `-`.
    #
    # ```ruby
    # "ABC cde".untitleize
    # # => "abc-cde"
    # ```
    #
    # @return [String] The untitleized version of the string.
    def untitleize
      downcase.gsub(" ", "-")
    end

    # Returns the string with all `&amp;` replaced with `&`.
    #
    # @return [String] The string with all `&amp;` replaced with `&`.
    def replace_ampersands
      gsub(/&amp;(\S+);/, "&\\1;")
    end

    # Returns the string itself for use in form helpers.
    #
    # @return [String] The string itself.
    def value
      self
    end
  end
end
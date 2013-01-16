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
      silence_warnings {
        self.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n, "").to_s
      }
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
      self.downcase.gsub(" ", "-")
    end

    # Returns the string with all `&amp;` replaced with `&`.
    #
    # @return [String] The string with all `&amp;` replaced with `&`.
    def replace_ampersands
      self.gsub(/&amp;(\S+);/, "&\\1;")
    end

    # Returns the string itself for use in form helpers.
    #
    # @return [String] The string itself.
    def value
      self
    end
  end
end
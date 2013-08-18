# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Lazier
  # Extensions for the Pathname class.
  module Pathname
    extend ::ActiveSupport::Concern

    # Returns all the components that are included in this path.
    #
    # ```ruby
    # Pathname.new("/usr/bin/ruby").components
    # # => ["usr", "bin", "ruby"]
    # ```
    #
    # @return [Array] A list of all components that are included in this path.
    def components
      each_filename.to_a
    end
  end
end
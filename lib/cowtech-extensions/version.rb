# encoding: utf-8
#
# This file is part of the cowtech-extensions gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Cowtech
  module Extensions
    # The current version of cowtech-extensions, according semantic versioning.
    #
    # @see http://semver.org
    module Version
      # The major version.
      MAJOR = 2

      # The minor version.
      MINOR = 7

      # The patch version.
      PATCH = 1

      # The current version of cowtech-extensions.
      STRING = [MAJOR, MINOR, PATCH].compact.join(".")
    end
  end
end

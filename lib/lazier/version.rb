# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2012 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Lazier
  # The current version of lazier, according to semantic versioning.
  #
  # @see http://semver.org
  module Version
    # The major version.
    MAJOR = 1

    # The minor version.
    MINOR = 0

    # The patch version.
    PATCH = 6

    # The current version of lazier.
    STRING = [MAJOR, MINOR, PATCH].compact.join(".")
  end
end

# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Lazier
  # The current version of lazier, according to semantic versioning.
  #
  # @see http://semver.org
  module Version
    # The major version.
    MAJOR = 3

    # The minor version.
    MINOR = 3

    # The patch version.
    PATCH = 0

    # The current version of lazier.
    STRING = [MAJOR, MINOR, PATCH].compact.join(".")
  end
end

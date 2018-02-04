#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

module Lazier
  # The current version of lazier, according to semantic versioning.
  #
  # @see http://semver.org
  module Version
    # The major version.
    MAJOR = 4

    # The minor version.
    MINOR = 2

    # The patch version.
    PATCH = 2

    # The current version of lazier.
    STRING = [MAJOR, MINOR, PATCH].compact.join(".")
  end
end

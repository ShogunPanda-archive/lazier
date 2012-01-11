# encoding: utf-8
#
# This file is part of the cowtech-extensions gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Cowtech
  module Extensions
    module Math
      extend ActiveSupport::Concern
  
      module ClassMethods
        def self.max(a, b)
          a > b ? a : b
        end

        def self.min(a, b)
          a < b ? a : b
        end
      end
    end
  end
end
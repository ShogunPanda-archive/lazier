# encoding: utf-8
#
# This file is part of the cowtech-extensions gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "active_support"

module Cowtech
  module Extensions
    module String
      extend ActiveSupport::Concern

      module InstanceMethods
        def remove_accents
          self.mb_chars.normalize(:kd).gsub(/[^\-x00-\x7F]/n, '').to_s
        end
  
        def untitleize
          self.downcase.gsub(" ", "-") 
        end
  
        def replace_ampersands
          self.gsub(/&amp;(\S+);/, "&\\1;") 
        end
        
        def value
          self
        end
      end
    end
  end
end
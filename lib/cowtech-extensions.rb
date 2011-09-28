# encoding: utf-8
#
# This file is part of the cowtech-extensions gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "cowtech-extensions/object"
require "cowtech-extensions/boolean"
require "cowtech-extensions/string"
require "cowtech-extensions/hash"
require "cowtech-extensions/datetime"
require "cowtech-extensions/math"
require "cowtech-extensions/pathname"

module Cowtech
  module Extensions
    def self.load!(what = [])
      what = ["object", "boolean", "string", "hash", "datetime", "math", "pathname"] if what.count == 0
      what.collect! { |w| w.to_s }

      yield if block_given?
      
      if what.include?("object") then
        ::Object.class_eval do
          include Cowtech::Extensions::Object
        end
      end
      
      if what.include?("boolean") then
        ::TrueClass.class_eval do
          include Cowtech::Extensions::Object
          include Cowtech::Extensions::Boolean
        end

        ::FalseClass.class_eval do
          include Cowtech::Extensions::Object
          include Cowtech::Extensions::Boolean
        end
      end
      
      if what.include?("string") then      
        ::String.class_eval do
          include Cowtech::Extensions::String
        end
      end

      if what.include?("hash") then
        ::Hash.class_eval do
          include Cowtech::Extensions::Hash  
        end
      end

      if what.include?("datetime") then
        ::Time.class_eval do
          include Cowtech::Extensions::DateTime
        end
        
        ::Date.class_eval do
          include Cowtech::Extensions::DateTime
        end

        ::DateTime.class_eval do
          include Cowtech::Extensions::DateTime
        end
        
        ::Date.setup_localization
        ::Time.setup_localization
        ::DateTime.setup_localization        
      end

      if what.include?("math") then
        ::Math.class_eval do
          include Cowtech::Extensions::Math
        end
      end

      if what.include?("pathname") then
        require "pathname"
        
        ::Pathname.class_eval do
          include Cowtech::Extensions::Pathname  
        end
      end
    end
  end
end
    
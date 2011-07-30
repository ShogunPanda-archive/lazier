# encoding: utf-8
#
# This file is part of the cowtech-extensions gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "pathname"
require "cowtech-extensions/object"
require "cowtech-extensions/boolean"
require "cowtech-extensions/string"
require "cowtech-extensions/hash"
require "cowtech-extensions/datetime"
require "cowtech-extensions/math"
require "cowtech-extensions/pathname"
require "cowtech-extensions/active_record" if defined?(ActiveRecord)

module Cowtech
  module Extensions
    def self.load!(what = [])
      what = ["object", "boolean", "string", "hash", "pathname", "datetime", "math", "active_record"] if what.count == 0
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

      if what.include?("string") then
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
      end

      if what.include?("math") then
        ::Math.class_eval do
          include Cowtech::Extensions::Math
        end
      end

      if what.include?("pathname") then
        ::Pathname.class_eval do
          include Cowtech::Extensions::Pathname  
        end
      end

      if defined?(ActiveRecord) && what.include?("active_record") then
        ::ActiveRecord::Base.class_eval do
          include Cowtech::Extensions::AR
        end
      end      
    end
  end
end
    
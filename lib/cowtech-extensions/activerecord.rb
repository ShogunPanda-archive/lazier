# encoding: utf-8
#
# This file is part of the cowtech-extensions gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Cowtech
  module Extensions
    module ActiveRecord
      extend ActiveSupport::Concern
  
      module ClassMethods
        if defined?(Rails) then
          def self.table_prefix
            p = ActiveRecord::Base.configurations[Rails.env]["table_prefix"]
            !p.blank? ? p + "_" : ""
          end

          def self.table_suffix
            p = ActiveRecord::Base.configurations[Rails.env]["table_suffix"]
            !p.blank? ? p + "_" : ""
          end
        end
        
        def self.set_table_name(value = nil, &block)  
          define_attr_method :table_name, "#{ActiveRecord::Base.table_prefix}#{value}#{ActiveRecord::Base.table_suffix}", &block  
        end

        def self.find_or_create(oid, attributes = nil)
          begin
            self.find(oid)
          rescue ActiveRecord::RecordNotFound
            self.new(attributes)
          end
        end

        def self.safe_find(oid)
          begin
            rv = self.find(oid)
          rescue ActiveRecord::RecordNotFound
            nil
          end
        end

        def self.random
          c = self.count
          c != 0 ? self.find(:first, :offset => rand(c)) : nil
        end

        def self.per_page
          25
        end
      end

      module InstanceMethods

      end
    end
  end
end
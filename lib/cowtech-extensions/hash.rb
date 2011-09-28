# encoding: utf-8
#
# This file is part of the cowtech-extensions gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Cowtech
  module Extensions
    module Hash
      extend ActiveSupport::Concern

      module InstanceMethods
        def method_missing(method, *args, &block)
          (self.has_key?(method.to_sym) || self.has_key?(method.to_s)) ? (self[method.to_sym] || self[method.to_s]) : super(method, *args, &block)
        end

        def respond_to?(method)
          (self.has_key?(method.to_sym) || self.has_key?(method.to_s)) ? true : super(method)
        end
      end
    end
  end
end
# encoding: utf-8
#
# This file is part of the cowtech-extensions gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Cowtech::Extensions::Boolean do
  describe "#to_i" do
    it "should return 1 for true" do true.to_i.should == 1 end
    it "should return 0 for false" do false.to_i.should == 0 end
  end

  describe "#value" do
    it "should return self" do
      true.value.should be_true
      false.value.should be_false
    end
  end
end
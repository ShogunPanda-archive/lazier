# encoding: utf-8
#
# This file is part of the cowtech-extensions gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Cowtech::Extensions::Hash do
  let(:reference) {
    rv = {:a => 1, "b" => 2}
    rv.default = 0
    rv
  }

  describe "#method_missing" do
    it "should allow method reference for string key" do reference.a.should == 1 end
    it "should allow method reference for symbol key" do reference.b.should == 2 end
    it "should use super for missing key" do expect {reference.c}.to raise_error(NoMethodError) end
  end

  describe "#respond_to" do
    it "should return true for string key" do reference.respond_to?(:a).should be_true end
    it "should return true for symbol key" do reference.respond_to?(:b).should be_true end
    it "should return false for missing key" do reference.respond_to?(:c).should be_false end
  end
end
# encoding: utf-8
#
# This file is part of the cowtech-extensions gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Cowtech::Extensions::Math do
  let(:first) { 1 }
  let(:second) { 2 }
  let(:third) { 0 }

  describe "#min" do
    it "should return the minimum argument" do
      ::Math.min().should be_nil
      ::Math.min(first).should == first
      ::Math.min(first, second).should == first
      ::Math.min([first, [second, third]]).should == third
    end
  end

  describe "#max" do
    it "should return the maximum argument" do
      ::Math.min().should be_nil
      ::Math.max(first).should == first
      ::Math.max(first, second).should == second
      ::Math.max([first, [second, third]]).should == second
    end
  end
end
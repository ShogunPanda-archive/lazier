# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2012 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Lazier::Hash do
  let(:reference) {
    rv = {:a => 1, "b" => 2}
    rv.default = 0
    rv
  }

  before(:all) do
    ::Lazier.load!
  end

  describe "allows access to keys using method syntax" do
    it "should allow method reference for symbol key" do expect(reference.b).to eq(2) end
    it "should use super for missing key" do expect {reference.c}.to raise_error(NoMethodError) end
  end

  describe "#respond_to" do
    it "should return true for string key" do expect(reference.respond_to?(:a)).to be_true end
    it "should return true for symbol key" do expect(reference.respond_to?(:b)).to be_true end
    it "should return false for missing key" do expect(reference.respond_to?(:c)).to be_false end
  end
end
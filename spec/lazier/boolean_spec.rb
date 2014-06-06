#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Lazier::Boolean do
  before(:all) do
    ::Lazier.load!(:boolean)
  end

  describe "#to_i" do
    it "should return 1 for true" do
      expect(true.to_i).to eq(1)
    end

    it "should return 0 for false" do
      expect(false.to_i).to eq(0)
    end
  end

  describe "#value" do
    it "should return self" do
      expect(true.value).to be_truthy
      expect(false.value).to be_falsey
    end
  end
end
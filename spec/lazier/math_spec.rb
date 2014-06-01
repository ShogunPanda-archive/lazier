#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Lazier::Math do
  let(:first) { 1 }
  let(:second) { 2 }
  let(:third) { 0 }

  before(:all) do
    ::Lazier.load!
  end

  describe "::min" do
    it "should return the minimum argument" do
      expect(::Math.min(first)).to eq(first)
      expect(::Math.min(first, second)).to eq(first)
      expect(::Math.min([first, [second, third]])).to eq(third)
    end

    it "should return nil for an empty array" do
      expect(::Math.min).to be_nil
    end
  end

  describe "::max" do
    it "should return the maximum argument" do
      expect(::Math.max(first)).to eq(first)
      expect(::Math.max(first, second)).to eq(second)
      expect(::Math.max([first, [second, third]])).to eq(second)
    end

    it "should return nil for an empty array" do
      expect(::Math.max).to be_nil
    end
  end
end
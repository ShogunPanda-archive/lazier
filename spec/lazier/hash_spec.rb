# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Lazier::Hash do
  let(:reference) {
    rv = {a: 1, "b" => {c: 2, d: {"e" => 3}}}
    rv.default = 0
    rv
  }

  before(:each) do
    ::Lazier.load!
  end

  describe "allows access to keys using dotted notation" do
    it "should allow method reference for symbol key" do
      reference.b.f = 4

      expect(reference.a).to eq(1)
      expect(reference.b.c).to eq(2)
      expect(reference["b"]["f"]).to eq(4)
    end
  end

  describe "#ensure_access" do
    it "should make sure that the requested access is granted" do
      expect({"a" => "b"}.ensure_access(:strings)).to eq({"a" => "b"})
      expect({"a" => "b"}.ensure_access(:symbols)).to eq({a: "b"})
      expect({"a" => "b"}.ensure_access(:indifferent)).to be_a(::HashWithIndifferentAccess)
      expect({"a" => "b"}.ensure_access(:other)).to eq({"a" => "b"})
      expect({a: "b"}.ensure_access(:strings)).to eq({"a" => "b"})
      expect({a: "b"}.ensure_access(:symbols)).to eq({a: "b"})
      expect({a: "b"}.ensure_access(:indifferent)).to be_a(::HashWithIndifferentAccess)
      expect({a: "b"}.ensure_access(:other)).to eq({a: "b"})
    end
  end
end
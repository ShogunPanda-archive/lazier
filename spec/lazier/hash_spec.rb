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


  describe "method access" do
    it "it is not enabled by default" do
      expect { reference.b }.to raise_error(NoMethodError)
    end
  end

  describe "allows access to keys using dotted notation" do
    before(:each) do
      ::Lazier.load!(:hash_method_access)
    end

    it "should allow method reference for symbol key" do
      reference.b.f = 4

      expect(reference.a).to eq(1)
      expect(reference.b.c).to eq(2)
      expect(reference["b"]["f"]).to eq(4)
    end
  end

  describe "#compact" do
    it "should remove blank keys" do
      expect({a: 1, b: nil}.compact).to eq({a: 1})
    end

    it "should use a custom validator" do
      expect({a: 1, b: nil, c: 3}.compact {|k, v| v == 1 || k == :c}).to eq({b: nil})
    end

    it "should not be destructive" do
      reference = {a: 1, b: nil}
      reference.compact
      expect(reference).to eq({a: 1, b: nil})
    end
  end

  describe "#compact!" do
    it "should remove blank keys" do
      reference = {a: 1, b: nil}
      reference.compact!
      expect(reference).to eq({a: 1})
    end

    it "should use a custom validator" do
      reference = {a: 1, b: nil, c: 3}
      reference.compact! {|k, v| v == 1 || k == :c}
      expect(reference).to eq({b: nil})
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

      reference.ensure_access(:dotted)
      expect(reference.a).to eq(1)
      expect(reference.b.c).to eq(2)
    end
  end

  describe "#with_dotted_access" do
    it "should recursively enable dotted access on a hash" do
      reference = {a: 1, b: {c: 3}, c: [1, {f: {g: 1}}]}

      reference.enable_dotted_access
      expect(reference.b.c).to eq(3)
      expect(reference.c[1].f.g).to eq(1)
    end

    it "should also provide write access if asked" do
      reference.enable_dotted_access(false)
      expect { reference.b.f = 4 }.not_to raise_error
      expect(reference["b"]["f"]).to eq(4)
    end
  end
end
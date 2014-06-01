#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Object do
  subject {
    rv = {a: 1, "b" => {c: 2, d: {"e" => 3}}}
    rv.default = 0
    rv
  }

  before(:each) do
    ::Lazier.load!
  end

  describe "#compact" do
    it "should remove blank keys" do
      expect({a: 1, b: nil}.compact).to eq({a: 1})
    end

    it "should use a custom validator" do
      expect({a: 1, b: nil, c: 3}.compact{|k, v| v == 1 || k == :c}).to eq({b: nil})
    end

    it "should not be destructive" do
      subject = {a: 1, b: nil}
      subject.compact
      expect(subject).to eq({a: 1, b: nil})
    end
  end

  describe "#compact!" do
    it "should remove blank keys" do
      subject = {a: 1, b: nil}
      subject.compact!
      expect(subject).to eq({a: 1})
    end

    it "should use a custom validator" do
      subject = {a: 1, b: nil, c: 3}
      subject.compact! {|k, v| v == 1 || k == :c}
      expect(subject).to eq({b: nil})
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

      accessed = subject.ensure_access(:indifferent, :dotted)
      expect(accessed[:a]).to eq(1)
      expect(accessed["a"]).to eq(1)
      expect(accessed.a).to eq(1)
      expect(accessed.b.c).to eq(2)
    end
  end

  describe "#with_dotted_access" do
    it "should recursively enable dotted access on a hash" do
      subject = {a: 1, b: {c: 3}, c: [1, {f: {g: 1}}]}

      subject.enable_dotted_access
      expect(subject.b.c).to eq(3)
      expect(subject.c[1].f.g).to eq(1)
    end

    it "should also provide write access if asked" do
      subject.enable_dotted_access(false)
      expect { subject.b.f = 4 }.not_to raise_error
      expect(subject["b"]["f"]).to eq(4)
    end
  end
end
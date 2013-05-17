# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
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
end
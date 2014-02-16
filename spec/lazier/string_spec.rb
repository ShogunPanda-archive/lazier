# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Lazier::String do
  let(:reference) { "abc òùà èé &amp;gt;" }
  let(:translated_reference) { "abc oua ee &amp;gt;" }
  let(:untitleized_reference) { "abc-òùà-èé-&amp;gt;" }
  let(:amp_reference) { "abc òùà èé &gt;" }

  before(:all) do
    ::Lazier.load!
  end

  describe "#remove_accents" do
    it "should translate accents" do
      expect(reference.remove_accents).to eq(translated_reference)
    end
  end

  describe "#ensure_valid_utf8" do
    if !defined?(JRUBY_VERSION) then
      it "converts to a valid UTF-8, leaving valid strings untouched" do
        expect("this is valid".ensure_valid_utf8).to eq("this is valid")
        expect("this is invalid - \xEA\xF3\xEF\xE8\xF2\xFC inv \xE2 \xC0\xC2\xD2\xCED\xCE\xCC\xE5 - \xE1\xEC\xE2 3 \xF1\xE5\xF0\xE8\xE8".ensure_valid_utf8).to eq("this is invalid -  inv  D -  3 ")
        expect("this is invalid - \xEA\xF3\xEF\xE8\xF2\xFC inv \xE2 \xC0\xC2\xD2\xCED\xCE\xCC\xE5 - \xE1\xEC\xE2 3 \xF1\xE5\xF0\xE8\xE8".ensure_valid_utf8("X")).to eq("this is invalid - XXXXXX inv X XXXXDXXX - XXX 3 XXXXX")
      end
    else
      it "raise an exception" do
        expect { "this is valid".ensure_valid_utf8 }.to raise_error(RuntimeError)
      end
    end
  end

  describe "#untitleize" do
    it "should convert spaces to dashes" do
      expect(reference.untitleize).to eq(untitleized_reference)
    end
  end

  describe "#replace_ampersands" do
    it "should remove HTML ampersands" do
      expect(reference.replace_ampersands).to eq(amp_reference)
    end
  end

  describe "#value" do
    it "should return the string itself" do
      expect(reference.value).to eq(reference)
      expect(translated_reference.value).to eq(translated_reference)
      expect(untitleized_reference.value).to eq(untitleized_reference)
      expect(amp_reference.value).to eq(amp_reference)
    end
  end

  describe "split_tokens" do
    it "should return a valid array" do
      expect("  1, 2,3,4,,,,,5,5".split_tokens()).to eq(["1", "2", "3", "4", "5", "5"])
      expect("  1, 2,3,4,,,,,5,5".split_tokens(false)).to eq(["1", "2", "3", "4", "", "", "", "", "5", "5"])
      expect("  1, 2,3,4,,,,,5,5".split_tokens(true, false)).to eq(["  1", "2", "3", "4", "5", "5"])
      expect("  1, 2,3,4,,,,,5,5".split_tokens(true, true, true)).to eq(["1", "2", "3", "4", "5"])
      expect("  1, 2,3,4,,,,,5,5".split_tokens(true, true, false, "@")).to eq(["1, 2,3,4,,,,,5,5"])
      expect("1@2@3@4@5".split_tokens(true, true, false, "@")).to eq(["1", "2", "3", "4", "5"])
    end
  end
end
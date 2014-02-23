# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Lazier::String do
  subject { "abc òùà èé &amp;gt;" }
  let(:translated_subject) { "abc oua ee &amp;gt;" }
  let(:untitleized_subject) { "abc-òùà-èé-&amp;gt;" }
  let(:amp_subject) { "abc òùà èé &gt;" }

  before(:all) do
    ::Lazier.load!
  end

  describe "#remove_accents" do
    it "should translate accents" do
      expect(subject.remove_accents).to eq(translated_subject)
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
      expect(subject.untitleize).to eq(untitleized_subject)
    end
  end

  describe "#replace_ampersands" do
    it "should remove HTML ampersands" do
      expect(subject.replace_ampersands).to eq(amp_subject)
    end
  end

  describe "#value" do
    it "should return the string itself" do
      expect(subject.value).to eq(subject)
      expect(translated_subject.value).to eq(translated_subject)
      expect(untitleized_subject.value).to eq(untitleized_subject)
      expect(amp_subject.value).to eq(amp_subject)
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
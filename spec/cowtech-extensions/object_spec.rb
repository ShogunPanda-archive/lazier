# encoding: utf-8
#
# This file is part of the cowtech-extensions gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Cowtech::Extensions::Object do
  before(:all) do
    ::Cowtech::Extensions.load!
  end

  describe "#normalize_number" do
    it "should correctly sanitize numbers" do
      expect(123.normalize_number).to eq("123")
      expect("123.45".normalize_number).to eq("123.45")
      expect("1,23.45".normalize_number).to eq("123.45")
      expect("-1.23.45".normalize_number).to eq("-123.45")
      expect("+123.45".normalize_number).to eq("+123.45")
      expect("+1.231,45".normalize_number).to eq("+1231.45")
    end
  end

  describe "#is_number?" do
    it "should return true for a valid number" do
      expect("123.45".is_number?).to be_true
      expect("1,23.45".is_number?).to be_true
      expect("-1.23.45".is_number?).to be_true
      expect("+123.45".is_number?).to be_true
      expect("+1.231,45".is_number?).to be_true
    end

    it "should return true for a invalid number" do
      expect("s213".is_number?).to be_false
      expect(nil.is_number?).to be_false
    end
  end

  describe "#is_integer?" do
    it "should return true for a valid number" do
      expect("123".is_integer?).to be_true
      expect("-123".is_integer?).to be_true
      expect("+123".is_integer?).to be_true
    end

    it "should return true for a invalid number" do
      expect("s123".is_integer?).to be_false
      expect("123.12".is_integer?).to be_false
    end
  end

  describe "#is_float?" do
    it "should return true for a valid number" do
      expect("123.45".is_float?).to be_true
      expect("1,23.45".is_float?).to be_true
      expect("-1.23.45".is_float?).to be_true
      expect("+123.45".is_float?).to be_true
      expect("+1.231,45".is_float?).to be_true
    end

    it "should return true for a invalid number" do
      expect("s213".is_float?).to be_false
      expect(nil.is_float?).to be_false
    end
  end

  describe "#is_boolean?" do
    it "should return true for a valid boolean" do
      expect(true.is_boolean?).to be_true
      expect(false.is_boolean?).to be_true
      expect(nil.is_boolean?).to be_true
      expect("y".is_boolean?).to be_true
      expect("n".is_boolean?).to be_true
      expect("yes".is_boolean?).to be_true
      expect("no".is_boolean?).to be_true
      expect("1".is_boolean?).to be_true
      expect("0".is_boolean?).to be_true
      expect("true".is_boolean?).to be_true
      expect("false".is_boolean?).to be_true
      expect("t".is_boolean?).to be_true
      expect("f".is_boolean?).to be_true
      expect(1.is_boolean?).to be_true
      expect(0.is_boolean?).to be_true
    end

    it "should return true for a invalid boolean" do
      expect("11".is_boolean?).to be_false
    end
  end

  describe "#ensure_string" do
    it "should correctly handle strings" do
      expect(" abc ".ensure_string).to eq(" abc ")
      1.ensure_string == "1"
      expect(1.0.ensure_string).to eq("1.0")
      expect(:abc.ensure_string).to eq("abc")
      expect(nil.ensure_string).to eq("")
    end
  end

  describe "#to_float" do
    it "should correctly convert number" do
      expect(123.45.to_float).to eq(123.45)
      expect(123.to_float).to eq(123.00)
      expect("123.45".to_float).to eq(123.45)
      expect("1,23.45".to_float).to eq(123.45)
      expect("-1.23.45".to_float).to eq(-123.45)
      expect("+123.45".to_float).to eq(123.45)
      expect("+1.231,45".to_float).to eq(1231.45)
    end

    it "should return 0.0 for a invalid number without a default" do
      expect("s213".to_float).to eq(0.0)
    end

    it "should return the default for a invalid number" do
      expect("s213".to_float(1.0)).to eq(1.0)
    end
  end

  describe "#to_integer" do
    it "should correctly convert number" do
      expect(123.45.to_integer).to eq(123)
      expect(123.to_integer).to eq(123)
      expect("+123".to_integer).to eq(123)
      expect("-123".to_integer).to eq(-123)
    end

    it "should return 0 for a invalid number without a default" do
      expect("s213".to_integer).to eq(0)
    end

    it "should return the default for a invalid number" do
      expect("s213".to_integer(1)).to eq(1)
    end
  end

  describe "#to_boolean" do
    it "should return true for a valid true boolean" do
      expect(true.to_boolean).to be_true
      expect("y".to_boolean).to be_true
      expect("yes".to_boolean).to be_true
      expect("1".to_boolean).to be_true
      expect(1.to_boolean).to be_true
      expect(1.0.to_boolean).to be_true
    end

    it "should return false for all other values" do
      expect(false.to_boolean).to be_false
      expect(nil.to_boolean).to be_false
      expect("n".to_boolean).to be_false
      expect("no".to_boolean).to be_false
      expect("2".to_boolean).to be_false
      expect(2.0.to_boolean).to be_false
      expect("false".to_boolean).to be_false
      expect("abc".to_boolean).to be_false
      expect(0.to_boolean).to be_false
    end
  end

  describe "#round_to_precision" do
    it "should round number" do
      expect(123.456789.round_to_precision(2)).to eq("123.46")
      expect(123.456789.round_to_precision(0)).to eq("123")
      expect("123.456789".round_to_precision(2)).to eq("123.46")
    end

    it "should return nil for non numeric values" do
      expect(123.456789.round_to_precision(-1)).to eq(nil)
      expect("abc".round_to_precision(-1)).to eq(nil)
    end
  end

  describe "#format_number" do
    it "should format number" do
      expect(123123.456789.format_number).to eq("123,123.46")
      expect(123123.456789.format_number(2)).to eq("123,123.46")
      expect(123123.456789.format_number(3, "@")).to eq("123,123@457")
      expect(123123.456789.format_number(3, "@", "$")).to eq("123,123@457 $")
      expect("123123.456789".format_number(3, "@", "$", "!")).to eq("123!123@457 $")

      Cowtech::Extensions.settings.setup_format_number(5, ",", "£", ".")
      expect(123123.456789.format_number).to eq("123.123,45679 £")
    end

    it "should return nil for non numeric values" do
      expect(123.456789.format_number(-1)).to eq(nil)
      expect("abc".format_number(-1)).to eq(nil)
    end
  end

  describe "#format_boolean" do
    it "should return the correct string for all values" do
      expect("yes".format_boolean).to eq("Yes")
      expect("abc".format_boolean).to eq("No")
    end

    it "should support localization" do
      Cowtech::Extensions.settings.setup_boolean_names("YYY", "NNN")
      expect("yes".format_boolean).to eq("YYY")
      expect("abc".format_boolean).to eq("NNN")
    end

    it "should support overrides" do
      Cowtech::Extensions.settings.setup_boolean_names
      expect("yes".format_boolean("TTT")).to eq("TTT")
      expect("yes".format_boolean(nil, "FFF")).to eq("Yes")
      expect("abc".format_boolean("TTT")).to eq("No")
      expect("abc".format_boolean(nil, "FFF")).to eq("FFF")
    end
  end

  describe "#debug_dump" do
    it "should return the correct representation for an object" do
      reference = {:a => "b"}
      expect(reference.debug_dump(:json, false)).to eq(reference.to_json)
      expect(reference.debug_dump(:pretty_json, false)).to eq(::JSON.pretty_generate(reference))
      expect(reference.debug_dump(:yaml, false)).to eq(reference.to_yaml)
    end

    it "should inspect the object if the format is not recognized" do
      reference = {:a => "b"}
      expect(reference.debug_dump(:unknown, false)).to eq(reference.inspect)
    end

    it "should raise an exception if requested" do
      expect { {:a => "b"}.debug_dump }.to raise_error(::Cowtech::Extensions::Exceptions::Dump)
    end
  end
end
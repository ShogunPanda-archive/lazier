# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Lazier::Object do
  before(:all) do
    ::Lazier.load!
  end

  describe "#normalize_number" do
    it "should correctly sanitize numbers" do
      expect(true.normalize_number).to eq("1")
      expect(false.normalize_number).to eq("0")
      expect(nil.normalize_number).to eq("0")
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

    it "should return false for a invalid number" do
      expect("s213".is_number?).to be_false
    end
  end

  describe "#is_integer?" do
    it "should return true for a valid number" do
      expect(true.is_integer?).to be_true
      expect(false.is_integer?).to be_true
      expect(nil.is_integer?).to be_true
      expect("123".is_integer?).to be_true
      expect("-123".is_integer?).to be_true
      expect("+123".is_integer?).to be_true
    end

    it "should return false for a invalid number" do
      expect("s123".is_integer?).to be_false
      expect("123.12".is_integer?).to be_false
    end
  end

  describe "#is_float?" do
    it "should return true for a valid number" do
      expect(true.is_float?).to be_true
      expect(false.is_float?).to be_true
      expect(nil.is_float?).to be_true
      expect("123.45".is_float?).to be_true
      expect("1,23.45".is_float?).to be_true
      expect("-1.23.45".is_float?).to be_true
      expect("+123.45".is_float?).to be_true
      expect("+1.231,45".is_float?).to be_true
    end

    it "should return false for a invalid number" do
      expect("s213".is_float?).to be_false
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

    it "should return false for a invalid boolean" do
      expect("11".is_boolean?).to be_false
    end
  end

  describe "#safe_send" do
    it "should run the method by default" do
      expect("STRING".safe_send(:gsub, "T", "E")).to eq("SERING")
      expect("STRING".safe_send(:gsub, "T") { "E" }).to eq("SERING")
    end

    it "should silently fail if the method is not supported" do
      expect("STRING".safe_send(:invalid_gsub, "T", "E")).to be_nil
    end
  end

  describe "#ensure" do
    it "should assign a default value to an object" do
      expect(nil.ensure("VALUE")).to eq("VALUE")
      expect([].ensure("VALUE")).to eq("VALUE")
      expect({}.ensure("VALUE")).to eq("VALUE")
      expect("".ensure("VALUE")).to eq("VALUE")
    end

    it "should use a different verifier" do
      expect(nil.ensure("VALUE", :present?)).to be_nil
      expect("".ensure("VALUE", :present?)).to eq("")
      expect("STRING".ensure("VALUE", :present?)).to eq("VALUE")
    end

    it "should use the provided block as verifier" do
      expect([].ensure("VALUE") {|o| o.length == 1} ).to eq([])
      expect(["STRING"].ensure("VALUE") {|o| o.length == 1} ).to eq("VALUE")
    end
  end

  describe "#ensure_string" do
    it "should correctly handle strings" do
      expect(" abc ".ensure_string).to eq(" abc ")
      expect(1.ensure_string).to eq("1")
      expect(1.0.ensure_string).to eq("1.0")
      expect(:abc.ensure_string).to eq("abc")
      expect(nil.ensure_string).to eq("")
    end

    it "should default to the default value for nil values" do
      expect(nil.ensure_string("DEFAULT")).to eq("DEFAULT")
    end

    it "should use a different method or the provided block to stringify value" do
      expect([1, 2, 3].ensure_string("", :join)).to eq("123")
      expect([1, 2, 3].ensure_string("-") {|a, v| a.join(v)} ).to eq("1-2-3")
    end
  end

  describe "#ensure_array" do
    it "should convert to an array with the object it self or a default value" do
      expect(nil.ensure_array).to eq([])
      expect("A".ensure_array).to eq(["A"])
      expect({a: "b"}.ensure_array).to eq([{a: "b"}])
      expect(nil.ensure_array(["1"])).to eq(["1"])
      expect("A".ensure_array(["2"])).to eq(["2"])
      expect({a: "b"}.ensure_array(["3"])).to eq(["3"])
    end

    it "should sanitize elements of the array using a method or a block" do
      expect(" 123 ".ensure_array).to eq([" 123 "])
      expect(" 123 ".ensure_array(nil, false, false, false, :strip)).to eq(["123"])
      expect(" 123 ".ensure_array(nil, false, false) { |e| e.reverse }).to eq([" 321 "])
    end

    it "should unicize, compact and flatten, array if requested to" do
      expect([1, 2, 3, nil, 3, 2, 1, [4]].ensure_array(nil, true, false)).to eq([1, 2, 3, nil, [4]])
      expect([1, 2, 3, nil, 3, 2, 1, [4]].ensure_array(nil, false, true)).to eq([1, 2, 3, 3, 2, 1, [4]])
      expect([1, 2, 3, nil, 3, 2, 1, [4]].ensure_array(nil, true, true)).to eq([1, 2, 3, [4]])
      expect([1, 2, 3, nil, 3, 2, 1, [4]].ensure_array(nil, true, true, true)).to eq([1, 2, 3, 4])
    end
  end

  describe "#ensure_hash" do
    it "should return an hash" do
      expect({a: "b"}.ensure_hash).to eq({a: "b"})
      expect(nil.ensure_hash(nil, {a: "b"})).to eq({a: "b"})

      expect(1.ensure_hash).to eq({})
      expect(1.ensure_hash(nil, :test)).to eq({test: 1})
      expect(1.ensure_hash(nil, "test")).to eq({"test" => 1})
      expect(1.ensure_hash(nil, 2)).to eq({key: 1})
    end

    it "should sanitize values" do
      expect(" 1 ".ensure_hash(nil, :key, &:strip)).to eq({key: "1"})
      expect(1.ensure_hash(nil, :key) { |v| v * 2 }).to eq({key: 2})
    end

    it "should grant access" do
      reference = {a: "b"}

      expect(reference).to receive(:ensure_access).with("ACCESS")
      reference.ensure_hash("ACCESS")
    end
  end

  describe "#to_float" do
    it "should correctly convert number" do
      expect(true.to_float).to eq(1.0)
      expect(false.to_float).to eq(0.0)
      expect(nil.to_float).to eq(0.0)
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
      expect(true.to_integer).to eq(1)
      expect(false.to_integer).to eq(0)
      expect(nil.to_integer).to eq(0)
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
      expect(true.to_boolean.class).to eq(TrueClass)
      expect("true".to_boolean.class).to eq(TrueClass)
      expect("y".to_boolean.class).to eq(TrueClass)
      expect("yes".to_boolean.class).to eq(TrueClass)
      expect("1".to_boolean.class).to eq(TrueClass)
      expect(1.to_boolean.class).to eq(TrueClass)
      expect(1.0.to_boolean.class).to eq(TrueClass)
    end

    it "should return false for all other values" do
      expect(false.to_boolean.class).to eq(FalseClass)
      expect(nil.to_boolean.class).to eq(FalseClass)
      expect("n".to_boolean.class).to eq(FalseClass)
      expect("no".to_boolean.class).to eq(FalseClass)
      expect("2".to_boolean.class).to eq(FalseClass)
      expect(2.0.to_boolean.class).to eq(FalseClass)
      expect("false".to_boolean.class).to eq(FalseClass)
      expect("abc".to_boolean.class).to eq(FalseClass)
      expect(0.to_boolean.class).to eq(FalseClass)
    end
  end

  describe "#round_to_precision" do
    it "should round number" do
      expect(123.456789.round_to_precision(2)).to eq(123.46)
      expect(123.456789.round_to_precision(0)).to eq(123)
      expect("123.456789".round_to_precision(2)).to eq(123.46)
      expect(123.456789.round_to_precision(-1)).to eq(123)
    end

    it "should return nil for non numeric values" do
      expect("abc".round_to_precision(-1)).to eq(nil)
    end
  end

  describe "#format_number" do
    it "should format number" do
      expect(123.format_number(0)).to eq("123")
      expect(123.456789.format_number).to eq("123.46")
      expect(12312.456789.format_number).to eq("12,312.46")
      expect(123123.456789.format_number).to eq("123,123.46")
      expect(1123123.456789.format_number).to eq("1,123,123.46")
      expect(123123.456789.format_number(2)).to eq("123,123.46")
      expect(123123.456789.format_number(3, "@")).to eq("123,123@457")
      expect(123123.456789.format_number(3, "@", "$")).to eq("123,123@457 $")
      expect("123123.456789".format_number(3, "@", "$", "!")).to eq("123!123@457 $")

      Lazier.settings.setup_format_number(5, ",", "£", ".")
      expect(123123.456789.format_number).to eq("123.123,45679 £")

      Lazier.settings.setup_format_number(2)
      expect(123.456789.format_number(-1)).to eq("123")
    end

    it "should return nil for non numeric values" do
      expect("abc".format_number(-1)).to eq(nil)
    end
  end

  describe "#format_boolean" do
    it "should return the correct string for all values" do
      expect("yes".format_boolean).to eq("Yes")
      expect("abc".format_boolean).to eq("No")
    end

    it "should support localization" do
      Lazier.settings.setup_boolean_names("YYY", "NNN")
      expect("yes".format_boolean).to eq("YYY")
      expect("abc".format_boolean).to eq("NNN")
    end

    it "should support overrides" do
      Lazier.settings.setup_boolean_names
      expect("yes".format_boolean("TTT")).to eq("TTT")
      expect("yes".format_boolean(nil, "FFF")).to eq("Yes")
      expect("abc".format_boolean("TTT")).to eq("No")
      expect("abc".format_boolean(nil, "FFF")).to eq("FFF")
    end
  end

  describe "#indexize" do
    it "should format for printing" do
      expect(1.indexize).to eq("01")
      expect(21.indexize(3, "A")).to eq("A21")
      expect(21.indexize(3, "A", :ljust)).to eq("21A")
    end
  end

  describe "#for_debug" do
    it "should return the correct representation for an object" do
      reference = {a: "b"}
      expect(reference.for_debug(:json, false)).to eq(reference.to_json)
      expect(reference.for_debug(:pretty_json, false)).to eq(::JSON.pretty_generate(reference))
      expect(reference.for_debug(:yaml, false)).to eq(reference.to_yaml)
    end

    it "should raise an exception if requested" do
      expect { {a: "b"}.for_debug }.to raise_error(::Lazier::Exceptions::Debug)
    end
  end
end
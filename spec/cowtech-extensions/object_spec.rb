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
      123.normalize_number.should == "123"
      "123.45".normalize_number.should == "123.45"
      "1,23.45".normalize_number.should == "123.45"
      "-1.23.45".normalize_number.should == "-123.45"
      "+123.45".normalize_number.should == "+123.45"
      "+1.231,45".normalize_number.should == "+1231.45"
    end
  end

  describe "#is_number?" do
    it "should return true for a valid number" do
      "123.45".is_number?.should be_true
      "1,23.45".is_number?.should be_true
      "-1.23.45".is_number?.should be_true
      "+123.45".is_number?.should be_true
      "+1.231,45".is_number?.should be_true
    end

    it "should return true for a invalid number" do
      "s213".is_number?.should be_false
      nil.is_number?.should be_false
    end
  end

  describe "#is_integer?" do
    it "should return true for a valid number" do
      "123".is_integer?.should be_true
      "-123".is_integer?.should be_true
      "+123".is_integer?.should be_true
    end

    it "should return true for a invalid number" do
      "s123".is_integer?.should be_false
      "123.12".is_integer?.should be_false
    end
  end

  describe "#is_float?" do
    it "should return true for a valid number" do
      "123.45".is_float?.should be_true
      "1,23.45".is_float?.should be_true
      "-1.23.45".is_float?.should be_true
      "+123.45".is_float?.should be_true
      "+1.231,45".is_float?.should be_true
    end

    it "should return true for a invalid number" do
      "s213".is_float?.should be_false
      nil.is_float?.should be_false
    end
  end

  describe "#is_boolean?" do
    it "should return true for a valid boolean" do
      true.is_boolean?.should be_true
      false.is_boolean?.should be_true
      nil.is_boolean?.should be_true
      "y".is_boolean?.should be_true
      "n".is_boolean?.should be_true
      "yes".is_boolean?.should be_true
      "no".is_boolean?.should be_true
      "1".is_boolean?.should be_true
      "0".is_boolean?.should be_true
      "true".is_boolean?.should be_true
      "false".is_boolean?.should be_true
      "t".is_boolean?.should be_true
      "f".is_boolean?.should be_true
      1.is_boolean?.should be_true
      0.is_boolean?.should be_true
    end

    it "should return true for a invalid boolean" do  "11".is_boolean?.should be_false end
  end

  describe "#ensure_string" do
    it "should correctly handle strings" do
      " abc ".ensure_string.should == " abc "
      1.ensure_string == "1"
      1.0.ensure_string.should == "1.0"
      :abc.ensure_string.should == "abc"
      nil.ensure_string.should == ""
    end
  end

  describe "#to_float" do
    it "should correctly convert number" do
      123.45.to_float.should == 123.45
      123.to_float.should == 123.00
      "123.45".to_float.should == 123.45
      "1,23.45".to_float.should == 123.45
      "-1.23.45".to_float.should == -123.45
      "+123.45".to_float.should == 123.45
      "+1.231,45".to_float.should == 1231.45
    end

    it "should return 0.0 for a invalid number without a default" do "s213".to_float.should == 0.0 end

    it "should return the default for a invalid number" do "s213".to_float(1.0).should == 1.0 end
  end

  describe "#to_integer" do
    it "should correctly convert number" do
      123.45.to_integer.should == 123
      123.to_integer.should == 123
      "+123".to_integer.should == 123
      "-123".to_integer.should == -123
    end

    it "should return 0 for a invalid number without a default" do "s213".to_integer.should == 0 end

    it "should return the default for a invalid number" do "s213".to_integer(1).should == 1 end
  end

  describe "#to_boolean" do
    it "should return true for a valid true boolean" do
      true.to_boolean.should be_true
      "y".to_boolean.should be_true
      "yes".to_boolean.should be_true
      "1".to_boolean.should be_true
      1.to_boolean.should be_true
      1.0.to_boolean.should be_true
    end

    it "should return false for all other values" do
      false.to_boolean.should be_false
      nil.to_boolean.should be_false
      "n".to_boolean.should be_false
      "no".to_boolean.should be_false
      "2".to_boolean.should be_false
      2.0.to_boolean.should be_false
      "false".to_boolean.should be_false
      "abc".to_boolean.should be_false
      0.to_boolean.should be_false
    end
  end

  describe "#round_to_precision" do
    it "should round number" do
      123.456789.round_to_precision(2).should == "123.46"
      123.456789.round_to_precision(0).should == "123"
      "123.456789".round_to_precision(2).should == "123.46"
    end

    it "should return nil for non numeric values" do
      123.456789.round_to_precision(-1).should == nil
      "abc".round_to_precision(-1).should == nil
    end
  end

  describe "#format_number" do
    it "should format number" do
      123123.456789.format_number.should == "123,123.46"
      123123.456789.format_number(2).should == "123,123.46"
      123123.456789.format_number(3, "@").should == "123,123@457"
      123123.456789.format_number(3, "@", "$").should == "123,123@457 $"
      "123123.456789".format_number(3, "@", "$", "!").should == "123!123@457 $"

      Cowtech::Extensions.settings.setup_format_number(5, ",", "£", ".")
      123123.456789.format_number.should == "123.123,45679 £"
    end

    it "should return nil for non numeric values" do
      123.456789.format_number(-1).should == nil
      "abc".format_number(-1).should == nil
    end
  end

  describe "#format_boolean" do
    it "should return the correct string for all values" do
      "yes".format_boolean.should == "Yes"
      "abc".format_boolean.should == "No"
    end

    it "should support localization" do
      Cowtech::Extensions.settings.setup_boolean_names("YYY", "NNN")
      "yes".format_boolean.should == "YYY"
      "abc".format_boolean.should == "NNN"
    end

    it "should support overrides" do
      Cowtech::Extensions.settings.setup_boolean_names
      "yes".format_boolean("TTT").should == "TTT"
      "yes".format_boolean(nil, "FFF").should == "Yes"
      "abc".format_boolean("TTT").should == "No"
      "abc".format_boolean(nil, "FFF").should == "FFF"
    end
  end

  describe "#debug_dump" do
    it "should return the correct representation for an object" do
      reference = {:a => "b"}
      reference.debug_dump(:json, false).should == reference.to_json
      reference.debug_dump(:pretty_json, false).should == ::JSON.pretty_generate(reference)
      reference.debug_dump(:yaml, false).should == reference.to_yaml
    end

    it "should inspect the object if the format is not recognized" do
      reference = {:a => "b"}
      reference.debug_dump(:unknown, false).should == reference.inspect
    end

    it "should raise an exception if requested" do expect { {:a => "b"}.debug_dump }.to raise_error(::Cowtech::Extensions::Exceptions::Dump) end
  end
end
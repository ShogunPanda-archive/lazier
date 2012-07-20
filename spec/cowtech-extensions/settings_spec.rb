# encoding: utf-8
#
# This file is part of the cowtech-extensions gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Cowtech::Extensions::Settings do
  let(:reference) { ::Cowtech::Extensions::Settings.instance }
  let(:number_reference) { 123456.654321 }
  let(:date_reference) { DateTime.civil(2005, 6, 7, 8, 9, 10, DateTime.rationalize_offset(25200)) }

  before(:all) do
    Cowtech::Extensions.load!
  end

  describe "#initialize" do
    it "should create good defaults" do
      settings = ::Cowtech::Extensions::Settings.new
      settings.format_number.should be_a(Hash)
      settings.boolean_names.should be_a(Hash)
      settings.date_names.should be_a(Hash)
      settings.date_formats.should be_a(Hash)
    end

    it "should create good defaults for the singleton" do
      reference.format_number.should be_a(Hash)
      reference.boolean_names.should be_a(Hash)
      reference.date_names.should be_a(Hash)
      reference.date_formats.should be_a(Hash)
    end
  end

  describe "#setup_format_number" do
    it "should save format numbering options for usage" do
      reference.setup_format_number(2)
      number_reference.format_number.should == "123,456.65"

      reference.setup_format_number(3, "A")
      number_reference.format_number.should == "123,456A654"

      reference.setup_format_number(4, "A", "B")
      number_reference.format_number.should == "123,456A6543 B"

      reference.setup_format_number(5, "A", "B", "C")
      number_reference.format_number.should == "123C456A65432 B"

      reference.setup_format_number
      number_reference.format_number.should == "123,456.65"
    end
  end

  describe "#setup_boolean_names" do
    it "should save names for boolean values" do
      reference.setup_boolean_names("TRUE1")
      [true.format_boolean, false.format_boolean].should == ["TRUE1", "No"]

      reference.setup_boolean_names(nil, "FALSE1")
      [true.format_boolean, false.format_boolean].should == ["Yes", "FALSE1"]

      reference.setup_boolean_names("TRUE2", "FALSE2")
      [true.format_boolean, false.format_boolean].should == ["TRUE2", "FALSE2"]

      reference.setup_boolean_names
      [true.format_boolean, false.format_boolean].should == ["Yes", "No"]
    end
  end

  describe "#setup_date_formats" do
    it "should save formats for date formatting" do
      reference.setup_date_formats(nil, true)

      reference.setup_date_formats({:c1 => "%Y"})
      date_reference.lstrftime(:ct_date) == date_reference.strftime("%Y-%m-%d")
      date_reference.lstrftime(:c1) == date_reference.year.to_s

      reference.setup_date_formats({:c1 => "%Y"}, true)
      date_reference.lstrftime(:ct_date).should == "ct_date"
      date_reference.lstrftime(:c1).should == date_reference.year.to_s

      reference.setup_date_formats()
      date_reference.lstrftime(:ct_date).should == date_reference.strftime("%Y-%m-%d")
      date_reference.lstrftime(:c1).should == date_reference.year.to_s

      reference.setup_date_formats(nil, true)
      date_reference.lstrftime(:ct_date) == date_reference.strftime("%Y-%m-d")
      date_reference.lstrftime(:c1).should == "c1"
    end
  end

  describe "#setup_date_names" do
    it "should save names for days and months" do
      reference.setup_date_names
      reference.setup_date_formats({:sdn => "%B %b %A %a"})

      long_months = 12.times.collect {|i| (i + 1).to_s * 2}
      short_months = 12.times.collect {|i| (i + 1).to_s}
      long_days = 7.times.collect {|i| (i + 1).to_s * 2}
      short_days = 7.times.collect {|i| (i + 1).to_s}

      reference.setup_date_names(long_months)
      date_reference.lstrftime(:sdn).should == "66 Jun Tuesday Tue"

      reference.setup_date_names(long_months, short_months)
      date_reference.lstrftime(:sdn).should == "66 6 Tuesday Tue"

      reference.setup_date_names(long_months, short_months, long_days)
      date_reference.lstrftime(:sdn).should == "66 6 33 Tue"

      reference.setup_date_names(long_months, short_months, long_days, short_days)
      date_reference.lstrftime(:sdn).should == "66 6 33 3"

      reference.setup_date_names
      date_reference.lstrftime(:sdn).should == "June Jun Tuesday Tue"
    end
  end
end
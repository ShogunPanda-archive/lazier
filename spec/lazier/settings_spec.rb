# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Lazier::Settings do
  let(:reference) { ::Lazier::Settings.instance }
  let(:number_reference) { 123456.654321 }
  let(:date_reference) { DateTime.civil(2005, 6, 7, 8, 9, 10, DateTime.rationalize_offset(25200)) }

  before(:all) do
    Lazier.load!
  end

  describe "#initialize" do
    it "should create good defaults" do
      settings = ::Lazier::Settings.new
      expect(settings.format_number).to be_a(Hash)
      expect(settings.boolean_names).to be_a(Hash)
      expect(settings.date_names).to be_a(Hash)
      expect(settings.date_formats).to be_a(Hash)
    end

    it "should create good defaults for the singleton" do
      expect(reference.format_number).to be_a(Hash)
      expect(reference.boolean_names).to be_a(Hash)
      expect(reference.date_names).to be_a(Hash)
      expect(reference.date_formats).to be_a(Hash)
    end
  end

  describe "#setup_format_number" do
    it "should save format numbering options for usage" do
      reference.setup_format_number(2)
      expect(number_reference.format_number).to eq("123,456.65")

      reference.setup_format_number(3, "A")
      expect(number_reference.format_number).to eq("123,456A654")

      reference.setup_format_number(4, "A", "B")
      expect(number_reference.format_number).to eq("123,456A6543 B")

      reference.setup_format_number(5, "A", "B", "C")
      expect(number_reference.format_number).to eq("123C456A65432 B")

      reference.setup_format_number
      expect(number_reference.format_number).to eq("123,456.65")
    end
  end

  describe "#setup_boolean_names" do
    it "should save names for boolean values" do
      reference.setup_boolean_names("TRUE1")
      expect([true.format_boolean, false.format_boolean]).to eq(["TRUE1", "No"])

      reference.setup_boolean_names(nil, "FALSE1")
      expect([true.format_boolean, false.format_boolean]).to eq(["Yes", "FALSE1"])

      reference.setup_boolean_names("TRUE2", "FALSE2")
      expect([true.format_boolean, false.format_boolean]).to eq(["TRUE2", "FALSE2"])

      reference.setup_boolean_names
      expect([true.format_boolean, false.format_boolean]).to eq(["Yes", "No"])
    end
  end

  describe "#setup_date_formats" do
    it "should save formats for date formatting" do
      reference.setup_date_formats(nil, true)

      reference.setup_date_formats({:c1 => "%Y"})
      expect(date_reference.lstrftime(:ct_date)).to eq(date_reference.strftime("%Y-%m-%d"))
      expect(date_reference.lstrftime(:c1)).to eq(date_reference.year.to_s)

      reference.setup_date_formats({:c1 => "%Y"}, true)
      expect(date_reference.lstrftime(:ct_date)).to eq("ct_date")
      expect(date_reference.lstrftime(:c1)).to eq(date_reference.year.to_s)

      reference.setup_date_formats()
      expect(date_reference.lstrftime(:ct_date)).to eq(date_reference.strftime("%Y-%m-%d"))
      expect(date_reference.lstrftime(:c1)).to eq(date_reference.year.to_s)

      reference.setup_date_formats(nil, true)
      expect(date_reference.lstrftime(:ct_date)).to eq(date_reference.strftime("%Y-%m-%d"))
      expect(date_reference.lstrftime(:c1)).to eq("c1")
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
      expect(date_reference.lstrftime(:sdn)).to eq("66 Jun Tuesday Tue")

      reference.setup_date_names(long_months, short_months)
      expect(date_reference.lstrftime(:sdn)).to eq("66 6 Tuesday Tue")

      reference.setup_date_names(long_months, short_months, long_days)
      expect(date_reference.lstrftime(:sdn)).to eq("66 6 33 Tue")

      reference.setup_date_names(long_months, short_months, long_days, short_days)
      expect(date_reference.lstrftime(:sdn)).to eq("66 6 33 3")

      reference.setup_date_names
      expect(date_reference.lstrftime(:sdn)).to eq("June Jun Tuesday Tue")
    end
  end
end
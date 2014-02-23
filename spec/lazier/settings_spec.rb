# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Lazier::Settings do
  let(:subject) { ::Lazier::Settings.instance }
  let(:number_subject) { 123456.654321 }
  let(:date_subject) { DateTime.civil(2005, 6, 7, 8, 9, 10, DateTime.rationalize_offset(25200)) }

  before(:all) do
    Lazier.load!
    ::Lazier::Settings.instance.i18n = :en
  end

  describe ".instance" do
    it "should create a new instance" do
      expect(::Lazier::Settings.instance).to be_a(::Lazier::Settings)
    end

    it "should always return the same instance" do
      instance = ::Lazier::Settings.instance
      expect(::Lazier::Settings).not_to receive(:new)
      expect(::Lazier::Settings.instance).to eq(instance)
    end

    it "should recreate an instance" do
      other = ::Lazier::Settings.instance
      expect(::Lazier::Settings.instance(true)).not_to eq(other)
    end
  end

  describe "#initialize" do
    it "should create good defaults" do
      settings = ::Lazier::Settings.new
      expect(settings.format_number).to be_a(::HashWithIndifferentAccess)
      expect(settings.boolean_names).to be_a(::Hash)
      expect(settings.date_names).to be_a(::HashWithIndifferentAccess)
      expect(settings.date_formats).to be_a(::HashWithIndifferentAccess)
    end
  end

  describe "#setup_format_number" do
    it "should save format numbering options for usage" do
      subject.setup_format_number(2)
      expect(number_subject.format_number).to eq("123,456.65")

      subject.setup_format_number(3, "A")
      expect(number_subject.format_number).to eq("123,456A654")

      subject.setup_format_number(4, "A", "B")
      expect(number_subject.format_number).to eq("123,456A6543 B")

      subject.setup_format_number(5, "A", "B", "C")
      expect(number_subject.format_number).to eq("123C456A65432 B")

      subject.setup_format_number
      expect(number_subject.format_number).to eq("123,456.65")
    end
  end

  describe "#setup_boolean_names" do
    it "should save names for boolean values" do
      subject.setup_boolean_names("TRUE1")
      expect([true.format_boolean, false.format_boolean]).to eq(["TRUE1", "No"])

      subject.setup_boolean_names(nil, "FALSE1")
      expect([true.format_boolean, false.format_boolean]).to eq(["Yes", "FALSE1"])

      subject.setup_boolean_names("TRUE2", "FALSE2")
      expect([true.format_boolean, false.format_boolean]).to eq(["TRUE2", "FALSE2"])

      subject.setup_boolean_names
      expect([true.format_boolean, false.format_boolean]).to eq(["Yes", "No"])
    end
  end

  describe "#setup_date_formats" do
    it "should save formats for date formatting" do
      subject.setup_date_formats(nil, true)

      subject.setup_date_formats({c1: "%Y"})
      expect(date_subject.lstrftime(:ct_date)).to eq(date_subject.strftime("%Y-%m-%d"))
      expect(date_subject.lstrftime("c1")).to eq(date_subject.year.to_s)

      subject.setup_date_formats({c1: "%Y"}, true)
      expect(date_subject.lstrftime("ct_date")).to eq("ct_date")
      expect(date_subject.lstrftime(:c1)).to eq(date_subject.year.to_s)

      subject.setup_date_formats
      expect(date_subject.lstrftime(:ct_date)).to eq(date_subject.strftime("%Y-%m-%d"))
      expect(date_subject.lstrftime("c1")).to eq(date_subject.year.to_s)

      subject.setup_date_formats(nil, true)
      expect(date_subject.lstrftime("ct_date")).to eq(date_subject.strftime("%Y-%m-%d"))
      expect(date_subject.lstrftime(:c1)).to eq("c1")
    end
  end

  describe "#setup_date_names" do
    it "should save names for days and months" do
      subject.i18n = :en
      subject.setup_date_names
      subject.setup_date_formats({sdn: "%B %b %A %a"})

      long_months = 12.times.map {|i| (i + 1).to_s * 2}
      short_months = 12.times.map {|i| (i + 1).to_s}
      long_days = 7.times.map {|i| (i + 1).to_s * 2}
      short_days = 7.times.map {|i| (i + 1).to_s}

      subject.setup_date_names(long_months)
      expect(date_subject.lstrftime(:sdn)).to eq("66 Jun Tuesday Tue")

      subject.setup_date_names(long_months, short_months)
      expect(date_subject.lstrftime("sdn")).to eq("66 6 Tuesday Tue")

      subject.setup_date_names(long_months, short_months, long_days)
      expect(date_subject.lstrftime(:sdn)).to eq("66 6 33 Tue")

      subject.setup_date_names(long_months, short_months, long_days, short_days)
      expect(date_subject.lstrftime("sdn")).to eq("66 6 33 3")

      subject.setup_date_names
      expect(date_subject.lstrftime(:sdn)).to eq("June Jun Tuesday Tue")
    end
  end
end
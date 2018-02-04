#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

require "spec_helper"

describe Lazier::DateTime do
  let(:random_subject) { ::DateTime.civil(1990 + rand(30), 1 + rand(10), 1 + rand(25), 1 + rand(20), 1 + rand(58), 1 + rand(58)).in_time_zone }
  let(:fixed_subject){ ::DateTime.civil(2005, 6, 7, 8, 9, 10, ::ActiveSupport::TimeZone.rationalize_offset(25200)) }
  let(:subject_zone) { ::ActiveSupport::TimeZone["Mountain Time (US & Canada)"] }
  let(:zone_without_dst) { ::ActiveSupport::TimeZone["International Date Line West"] }

  before(:all) do
    Lazier.load!(:datetime)
  end

  describe ".days" do
    it "should return the list of the days of the week" do
      expect(::DateTime.days).to be_a(::Array)
      expect(::DateTime.days[3]).to eq({value: "4", label: "Wed"})
      expect(::DateTime.days(false)).to be_a(::Array)
      expect(::DateTime.days(false)[3]).to eq({value: "4", label: "Wednesday"})

      ::Lazier.settings.setup_date_names(long_days: 7.times.map {|i| (i + 1).to_s * 2}, short_days: 7.times.map {|i| (i + 1).to_s})
      expect(::DateTime.days).to be_a(::Array)
      expect(::DateTime.days[3]).to eq({value: "4", label: "4"})
      expect(::DateTime.days(false)).to be_a(::Array)
      expect(::DateTime.days(false)[3]).to eq({value: "4", label: "44"})
    end
  end

  describe ".months" do
    it "should return the list of the months of the year" do
      expect(::DateTime.months).to be_a(::Array)
      expect(::DateTime.months[6]).to eq({value: "07", label: "Jul"})
      expect(::DateTime.months(false)).to be_a(::Array)
      expect(::DateTime.months(false)[6]).to eq({value: "07", label: "July"})

      ::Lazier.settings.setup_date_names(long_months: 12.times.map {|i| (i + 1).to_s * 2}, short_months: 12.times.map {|i| (i + 1).to_s})
      expect(::DateTime.months).to be_a(::Array)
      expect(::DateTime.months[6]).to eq({value: "07", label: "7"})
      expect(::DateTime.months(false)).to be_a(::Array)
      expect(::DateTime.months(false)[6]).to eq({value: "07", label: "77"})
    end
  end

  describe ".years" do
    it "should return a range of years" do
      expect(::DateTime.years).to eq((::Date.today.year - 10..::Date.today.year + 10).to_a)
      expect(::DateTime.years(offset: 5)).to eq((::Date.today.year - 5..::Date.today.year + 5).to_a)
      expect(::DateTime.years(as_objects: true).map {|d| d[:value]}).to eq((::Date.today.year - 10..::Date.today.year + 10).to_a)
      expect(::DateTime.years(also_future: false)).to eq((::Date.today.year - 10..::Date.today.year).to_a)
      expect(::DateTime.years(reference: 1900)).to eq((1890..1910).to_a)
    end
  end

  describe ".custom_format" do
    it "should find the format" do
      expect(::DateTime.custom_format(:ct_date)).to eq("%Y-%m-%d")
      expect(::DateTime.custom_format("ct_date")).to eq("%Y-%m-%d")

      ::Lazier.settings.setup_date_formats({ct_foo: "%ABC"})

      expect(::DateTime.custom_format(:ct_foo)).to eq("%ABC")
      expect(::DateTime.custom_format("ct_foo")).to eq("%ABC")
    end

    it "should return the key if format is not found" do
      ::DateTime.custom_format(:ct_unused) == "ct_unused"
    end
  end

  describe ".valid?" do
    it "should recognize a valid date" do
      expect(::DateTime.valid?("2012-04-05", "%F")).to be_truthy
      expect(::DateTime.valid?("2012-04-05", :ct_date)).to be_truthy
    end

    it "should fail if the argument or the format is not valid" do
      expect(::DateTime.valid?("ABC", "%F")).to be_falsey
      expect(::DateTime.valid?("2012-04-05", "%X")).to be_falsey
    end
  end

  describe ".easter" do
    it "should compute the valid Easter day" do
      {1984 => "0422", 1995 => "0416", 2006 => "0416", 2017 => "0416"}.each do |year, date|
        expect(::DateTime.easter(year).strftime("%Y%m%d")).to eq("#{year}#{date}")
      end
    end
  end

  describe "#months_since_year" do
    it "should return the amount of months passed since the start of the subject year" do
      expect(::Date.today.months_since_year).to eq(::Date.today.month)
      expect(fixed_subject.months_since_year(2000)).to eq(66)
    end
  end

  describe "#padded_month" do
    it "should pad the month number" do
      expect(random_subject.padded_month).to eq(random_subject.month.to_s.rjust(2, "0"))
      expect(::Date.civil(2000, 8, 8).padded_month).to eq("08")
    end
  end

  describe "#format" do
    it "should return corrected formatted string" do
      expect(fixed_subject.format(:db)).to eq("db")
      expect(fixed_subject.format("%F")).to eq("2005-06-07")
      expect(fixed_subject.format(:ct_iso_8601)).to eq("2005-06-07T08:09:10+0700")

      ::Lazier.settings.setup_date_names
      ::Lazier.settings.setup_date_formats({ct_local_test: "%a %A %b %B %d %Y %H"})
      expect(fixed_subject.format(:ct_local_test)).to eq("Tue Tuesday Jun June 07 2005 08")

      ::Lazier.settings.setup_date_names(
        long_months: 12.times.map {|i| (i + 1).to_s * 2}, short_months: 12.times.map {|i| (i + 1).to_s},
        long_days: 7.times.map {|i| (i + 1).to_s * 2}, short_days: 7.times.map {|i| (i + 1).to_s}
      )

      expect(fixed_subject.format(:ct_local_test)).to eq("3 33 6 66 07 2005 08")
    end

    it "should ignore custom formats if requested to" do
      expect(fixed_subject.format(:ct_iso_8601, custom: false)).to eq("ct_iso_8601")
    end

    it "should move in the current time zone if request to" do
      original_zone = ::Time.zone
      ::Time.zone = ::ActiveSupport::TimeZone[0]

      expect(fixed_subject.format(:ct_iso_8601, change_time_zone: true)).to eq("2005-06-07T01:09:10+0000")
      ::Time.zone = original_zone
    end
  end
end
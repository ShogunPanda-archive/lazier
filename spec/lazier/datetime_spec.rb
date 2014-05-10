# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Lazier::DateTime do
  let(:random_subject) { ::DateTime.civil(1990 + rand(30), 1 + rand(10), 1 + rand(25), 1 + rand(20), 1 + rand(58), 1 + rand(58)).in_time_zone }
  let(:fixed_subject){ ::DateTime.civil(2005, 6, 7, 8, 9, 10, ::DateTime.rationalize_offset(25200)) }
  let(:subject_zone) { ::ActiveSupport::TimeZone["Mountain Time (US & Canada)"] }
  let(:zone_without_dst) { ::ActiveSupport::TimeZone["International Date Line West"] }

  before(:all) do
    Lazier.load!
    ::Lazier::Settings.instance.i18n = :en
  end

  describe ".days" do
    it "should return the list of the days of the week" do
      expect(::DateTime.days).to be_a(::Array)
      expect(::DateTime.days[3]).to eq({value: "4", label: "Wed"})
      expect(::DateTime.days(false)).to be_a(::Array)
      expect(::DateTime.days(false)[3]).to eq({value: "4", label: "Wednesday"})

      ::Lazier.settings.setup_date_names(nil, nil, 7.times.map {|i| (i + 1).to_s * 2}, 7.times.map {|i| (i + 1).to_s})
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

      ::Lazier.settings.setup_date_names(12.times.map {|i| (i + 1).to_s * 2}, 12.times.map {|i| (i + 1).to_s}, nil, nil)
      expect(::DateTime.months).to be_a(::Array)
      expect(::DateTime.months[6]).to eq({value: "07", label: "7"})
      expect(::DateTime.months(false)).to be_a(::Array)
      expect(::DateTime.months(false)[6]).to eq({value: "07", label: "77"})
    end
  end

  describe ".years" do
    it "should return a range of years" do
      expect(::DateTime.years).to eq((::Date.today.year - 10..::Date.today.year + 10).to_a)
      expect(::DateTime.years(5)).to eq((::Date.today.year - 5..::Date.today.year + 5).to_a)
      expect(::DateTime.years(5, true, nil, true).map {|d| d[:value]}).to eq((::Date.today.year - 5..::Date.today.year + 5).to_a)
      expect(::DateTime.years(5, false)).to eq((::Date.today.year - 5..::Date.today.year).to_a)
      expect(::DateTime.years(5, false, 1900)).to eq((1895..1900).to_a)
    end
  end

  describe ".timezones" do
    it "should list all timezones" do
      expect(::DateTime.timezones).to eq(::ActiveSupport::TimeZone.all)
    end
  end

  describe ".list_timezones" do
    it "should forward to ActiveSupport::TimeZone" do
      expect(::ActiveSupport::TimeZone).to receive(:list_all)
      ::DateTime.list_timezones
    end
  end

  describe ".find_timezone" do
    it "should forward to ActiveSupport::TimeZone" do
      expect(::ActiveSupport::TimeZone).to receive(:find)
      ::DateTime.find_timezone(subject_zone.name)
    end
  end

  describe ".rationalize_offset" do
    it "should return the correct rational value" do
      expect(::ActiveSupport::TimeZone).to receive(:rationalize_offset)
      ::DateTime.rationalize_offset(0)
    end
  end

  describe ".parameterize_zone" do
    it "should forward to ActiveSupport::TimeZone" do
      expect(::ActiveSupport::TimeZone).to receive(:parameterize_zone)
      ::DateTime.parameterize_zone(subject_zone)
    end
  end

  describe ".unparameterize_zone" do
    it "should forward to ActiveSupport::TimeZone" do
      expect(::ActiveSupport::TimeZone).to receive(:unparameterize_zone)
      ::DateTime.unparameterize_zone(subject_zone)
    end
  end

  describe ".easter" do
    it "should compute the valid Easter day" do
      {1984 => "0422", 1995 => "0416", 2006 => "0416", 2017 => "0416"}.each do |year, date|
        expect(::DateTime.easter(year).strftime("%Y%m%d")).to eq("#{year}#{date}")
      end
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

  describe ".is_valid?" do
    it "should recognize a valid date" do
      expect(::DateTime.is_valid?("2012-04-05", "%F")).to be_true
      expect(::DateTime.is_valid?("2012-04-05", :ct_date)).to be_true
    end

    it "should fail if the argument or the format is not valid" do
      expect(::DateTime.is_valid?("ABC", "%F")).to be_false
      expect(::DateTime.is_valid?("2012-04-05", "%X")).to be_false
    end
  end

  describe "#utc_time" do
    it "should convert to UTC Time" do
      expect(random_subject.utc_time).to be_a(::Time)
    end
  end

  describe "#in_months" do
    it "should return the amount of months passed since the start of the subject year" do
      expect(::Date.today.in_months).to eq(::Date.today.month)
      expect(fixed_subject.in_months(2000)).to eq(66)
    end
  end

  describe "#padded_month" do
    it "should pad the month number" do
      expect(random_subject.padded_month).to eq(random_subject.month.to_s.rjust(2, "0"))
      expect(::Date.civil(2000, 8, 8).padded_month).to eq("08")
    end
  end

  describe "#lstrftime" do
    it "should return corrected formatted string" do
      expect(fixed_subject.lstrftime(:db)).to eq("db")
      expect(fixed_subject.lstrftime("%F")).to eq("2005-06-07")
      expect(fixed_subject.lstrftime(:ct_iso_8601)).to eq("2005-06-07T08:09:10+0700")

      ::Lazier.settings.setup_date_names
      ::Lazier.settings.setup_date_formats({ct_local_test: "%a %A %b %B %d %Y %H"})
      expect(fixed_subject.lstrftime(:ct_local_test)).to eq("Tue Tuesday Jun June 07 2005 08")

      ::Lazier.settings.setup_date_names(
          12.times.map {|i| (i + 1).to_s * 2}, 12.times.map {|i| (i + 1).to_s},
          7.times.map {|i| (i + 1).to_s * 2}, 7.times.map {|i| (i + 1).to_s}
      )

      expect(fixed_subject.lstrftime(:ct_local_test)).to eq("3 33 6 66 07 2005 08")
    end
  end

  describe "#local_strftime" do
    it "should retrieve the date in the current timezone" do
      ::Time.zone = ::ActiveSupport::TimeZone[0]
      ::Lazier.settings.setup_date_formats({ct_local_test: "%a %A %b %B %d %Y %H"})
      expect(fixed_subject.local_strftime(:ct_local_test)).to eq("Tue Tuesday Jun June 07 2005 01")
    end
  end

  describe "#local_lstrftime" do
    it "should retrieve the date in the current timezone" do
      ::Time.zone = ::ActiveSupport::TimeZone[0]

      ::Lazier.settings.setup_date_names
      ::Lazier.settings.setup_date_formats({ct_local_test: "%a %A %b %B %d %Y %H"})

      ::Lazier.settings.setup_date_names(
          12.times.map {|i| (i + 1).to_s * 2}, 12.times.map {|i| (i + 1).to_s},
          7.times.map {|i| (i + 1).to_s * 2}, 7.times.map {|i| (i + 1).to_s}
      )

      expect(fixed_subject.local_lstrftime(:ct_local_test)).to eq("3 33 6 66 07 2005 01")
    end
  end
end
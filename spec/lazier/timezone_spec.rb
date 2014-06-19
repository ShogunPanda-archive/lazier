#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Lazier::TimeZone do
  let(:subject_zone) { ::ActiveSupport::TimeZone["Mountain Time (US & Canada)"] }
  let(:subject_zone) { ::ActiveSupport::TimeZone["Mountain Time (US & Canada)"] }
  let(:zone_without_dst) { ::ActiveSupport::TimeZone["International Date Line West"] }

  before(:all) do
    ::Lazier.load!(:datetime)
    ::Time.zone = ::ActiveSupport::TimeZone["Mountain Time (US & Canada)"]
  end

  describe ".rationalize_offset" do
    it "should return the correct rational value" do
      expect(::ActiveSupport::TimeZone.rationalize_offset(-25200)).to eq(Rational(-7, 24))
    end
  end

  describe ".format_offset" do
    it "should correctly format an offset" do
      expect(::ActiveSupport::TimeZone.format_offset(-25200)).to eq("-07:00")
      expect(::ActiveSupport::TimeZone.format_offset(Rational(-4, 24), false)).to eq("-0400")
    end
  end

  describe ".find" do
    it "should find timezones" do
      expect(::ActiveSupport::TimeZone.find("(GMT-07:00) Mountain Time (US & Canada)")).to eq(subject_zone)
      expect(::ActiveSupport::TimeZone.find("(GMT-06:00) Mountain Time (US & Canada) (DST)")).to eq(subject_zone)
      expect(::ActiveSupport::TimeZone.find("(GMT-06:00) Mountain Time (US & Canada) Daylight Saving Time", " Daylight Saving Time")).to eq(subject_zone)
      expect(::ActiveSupport::TimeZone.find("INVALID", "INVALID")).to be_nil
    end
  end

  describe ".list" do
    it "should list all timezones as list" do
      expect(::ActiveSupport::TimeZone.list(false)).to include("(GMT-11:00) Pacific/American Samoa", "(GMT-11:00) International Date Line West")
      expect(::ActiveSupport::TimeZone.list(false).first).to eq("(GMT+01:00) Africa/Algiers")
      expect(::ActiveSupport::TimeZone.list(false, sort_by_name: false).first).to eq("(GMT-11:00) Pacific/American Samoa")
      expect(::ActiveSupport::TimeZone.list(false)).to include("(GMT-11:00) Pacific/American Samoa", "(GMT-11:00) International Date Line West")
      expect(::ActiveSupport::TimeZone.list(true)).to include("(GMT-06:00) #{subject_zone.aliases.first} (DST)")
      expect(::ActiveSupport::TimeZone.list(true, dst_label: " Daylight Saving Time")).to include("(GMT-06:00) #{subject_zone.aliases.first} Daylight Saving Time")
      expect(::ActiveSupport::TimeZone.list(true, parameterized: true)).to include("-0600@mountain-time-us-canada-dst")
    end

    it "should list all timezones as hash" do
      expect(::ActiveSupport::TimeZone.list(true, sort_by_name: true, as_hash: true)["(GMT-06:00) #{subject_zone.aliases.first} (DST)"]).to eq(subject_zone)
      expect(::ActiveSupport::TimeZone.list(true, sort_by_name: true, as_hash: true).keys.first).to eq("(GMT+01:00) Africa/Algiers")
      expect(::ActiveSupport::TimeZone.list(true, sort_by_name: false, as_hash: true).keys.first).to eq("(GMT-11:00) Pacific/American Samoa")
      expect(::ActiveSupport::TimeZone.list(true, as_hash: true, parameterized: true)).to include("-0700@mountain-time-us-canada")

    end
  end

  describe ".parameterize" do
    it "should return the parameterized version of the zone" do
      expect(::ActiveSupport::TimeZone.parameterize(subject_zone)).to eq("-0700@mountain-time-us-canada")
      expect(::ActiveSupport::TimeZone.parameterize(subject_zone.to_str)).to eq("-0700@mountain-time-us-canada")
      expect(::ActiveSupport::TimeZone.parameterize(subject_zone, false)).to eq("mountain-time-us-canada")
      expect(::ActiveSupport::TimeZone.parameterize("INVALID")).to eq("invalid")
      expect(::ActiveSupport::TimeZone.parameterize("-0700@mountain-time-us-canada")).to eq("-0700@mountain-time-us-canada")
    end
  end

  describe ".unparameterize" do
    it "should return the parameterized version of the zone" do
      expect(::ActiveSupport::TimeZone.unparameterize("-0700@mountain-time-us-canada")).to eq(subject_zone)
      expect(::ActiveSupport::TimeZone.unparameterize("mountain-time-us-canada")).to be_nil
      expect(::ActiveSupport::TimeZone.unparameterize("-0600@mountain-time-us-canada-day", " DAY")).to eq(subject_zone)
      expect(::ActiveSupport::TimeZone.unparameterize(subject_zone.to_str)).to eq(subject_zone)
      expect(::ActiveSupport::TimeZone.unparameterize("INVALID")).to eq(nil)
    end
  end

  describe "#compare" do
    it "should correctly compare timezones" do
      expect(::ActiveSupport::TimeZone.compare(::ActiveSupport::TimeZone["Africa/Algiers"], ::ActiveSupport::TimeZone["International Date Line West"])).to eq(-1)
      expect(::ActiveSupport::TimeZone.compare(::ActiveSupport::TimeZone["Africa/Algiers"], ::ActiveSupport::TimeZone["Africa/Algiers"])).to eq(0)
      expect(::ActiveSupport::TimeZone.compare(::ActiveSupport::TimeZone["Europe/Madrid"], ::ActiveSupport::TimeZone["Europe/Copenhagen"])).to eq(1)
      expect(::ActiveSupport::TimeZone.compare("(GMT+01:00) Europe/Rome", "(GMT+02:00) Europe/Kiev")).to eq(1)
    end
  end

  describe "#aliases" do
    it "should return the right list of aliases" do
      expect(ActiveSupport::TimeZone["America/Los_Angeles"].aliases).to eq(["America/Los Angeles", "Pacific Time (US & Canada)"])
    end
  end

  describe "#current_offset" do
    it "should correctly return current zone offset" do
      expect(subject_zone.current_offset(false, ::DateTime.civil(2012, 1, 15))).to eq(-25200)
      expect(subject_zone.current_offset(true, ::DateTime.civil(2012, 7, 15))).to eq(Rational(-1, 4))
    end
  end

  describe "#current_alias" do
    it "should correctly return current zone alias or the first one" do
      zone = ActiveSupport::TimeZone["America/Halifax"]
      expect(zone.current_alias).to eq("America/Halifax")
      allow(zone).to receive(:name).and_return("INVALID")
      expect(zone.current_alias).to eq("America/Atlantic Time (Canada)")
    end
  end

  describe "#current_alias=" do
    it "should set the current alias alias" do
      zone = ActiveSupport::TimeZone["America/Halifax"]
      zone.current_alias = "ALIAS"
      expect(zone.current_alias).to eq("ALIAS")
    end
  end

  describe "#current_name" do
    it "should correctly get zone name with Daylight Saving Time" do
      expect(subject_zone.current_name).to eq("Mountain Time (US & Canada)")
      expect(subject_zone.current_name(true)).to eq("Mountain Time (US & Canada) (DST)")
      expect(subject_zone.current_name(true, dst_label: "-dst")).to eq("Mountain Time (US & Canada)-dst")
      expect(subject_zone.current_name(true, year: 1000)).to eq("Mountain Time (US & Canada)")
    end
  end

  describe "#offset" do
    it "should correctly return zone offset" do
      expect(subject_zone.offset).to eq(subject_zone.utc_offset)
    end
  end

  describe "#uses_dst?" do
    it "should correctly detect offset usage" do
      expect(subject_zone.uses_dst?).to be_truthy
      expect(subject_zone.uses_dst?(::DateTime.civil(2012, 7, 15))).to be_truthy
      expect(subject_zone.uses_dst?(::DateTime.civil(2012, 1, 15))).to be_falsey
      expect(subject_zone.uses_dst?(1000)).to be_falsey
      expect(zone_without_dst.uses_dst?).to be_falsey
    end
  end

  describe "#dst_period" do
    it "should correctly return zone offset" do
      expect(subject_zone.dst_period).to be_a(::TZInfo::TimezonePeriod)
      expect(subject_zone.dst_period(1000)).to be_nil
      expect(zone_without_dst.dst_period).to be_nil

      expect(zone_without_dst).to receive(:period_for_utc).and_raise(RuntimeError)
      expect(zone_without_dst.dst_period).to be_nil
    end
  end

  describe "#dst_correction" do
    it "should correctly detect offset usage" do
      expect(subject_zone.dst_correction).to eq(3600)
      expect(subject_zone.dst_correction(true)).to eq(Rational(1, 24))
      expect(subject_zone.dst_correction(false, 1000)).to eq(0)
      expect(zone_without_dst.dst_correction).to eq(0)
    end
  end

  describe "#to_str" do
    describe "parameterized" do
      it "should correctly parameterize the zone" do
        expect(subject_zone.to_str(parameterized: true, label: "FOO")).to eq("-0700@foo")
        expect(subject_zone.to_str(parameterized: true)).to eq("-0700@mountain-time-us-canada")
        expect(subject_zone.to_str(true, parameterized: true)).to eq("-0600@mountain-time-us-canada-dst")
        expect(subject_zone.to_str(true, parameterized: true, dst_label: "-DAY")).to eq("-0600@mountain-time-us-canada-day")
        expect(subject_zone.to_str(true, parameterized: true, utc_label: "UTC")).to eq("-0600@mountain-time-us-canada-dst")
        expect(subject_zone.to_str(parameterized: true, year: 1000)).to eq("-0700@mountain-time-us-canada")
        expect(subject_zone.to_str(parameterized: true, with_offset: false)).to eq("mountain-time-us-canada")
      end
    end

    describe "not parameterized" do
      it "should correctly parameterize the zone" do
        expect(subject_zone.to_str(label: "FOO")).to eq("(GMT-07:00) FOO")
        expect(subject_zone.to_str).to eq("(GMT-07:00) Mountain Time (US & Canada)")
        expect(subject_zone.to_str(true)).to eq("(GMT-06:00) Mountain Time (US & Canada) (DST)")
        expect(subject_zone.to_str(true, dst_label: "-DAY")).to eq("(GMT-06:00) Mountain Time (US & Canada)-DAY")
        expect(subject_zone.to_str(true, utc_label: "UTC")).to eq("(UTC-06:00) Mountain Time (US & Canada) (DST)")
        expect(subject_zone.to_str(year: 1000)).to eq("(GMT-07:00) Mountain Time (US & Canada)")
        expect(subject_zone.to_str(with_offset: false)).to eq("Mountain Time (US & Canada)")
        expect(subject_zone.to_str(offset_position: :end)).to eq("Mountain Time (US & Canada) (GMT-07:00)")
        expect(subject_zone.to_str(offset_position: :other)).to eq("(GMT-07:00) Mountain Time (US & Canada)")
        expect(subject_zone.to_str(colon: false)).to eq("(GMT-0700) Mountain Time (US & Canada)")
        expect(subject_zone.to_str).to eq("(GMT-07:00) Mountain Time (US & Canada)")
      end
    end
  end
end
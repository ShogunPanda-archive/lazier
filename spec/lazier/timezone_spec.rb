# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Lazier::TimeZone do
  let(:subject_zone) { ::ActiveSupport::TimeZone["Mountain Time (US & Canada)"] }
  let(:zone_without_dst) { ::ActiveSupport::TimeZone["International Date Line West"] }

  before(:all) do
    ::Lazier.load!
    ::Lazier::Settings.instance(true)
    ::Lazier::Settings.instance.i18n = :en
  end

  describe ".rationalize_offset" do
    it "should return the correct rational value" do
      expect(::ActiveSupport::TimeZone.rationalize_offset(::ActiveSupport::TimeZone[4])).to eq(Rational(1, 6))
      expect(::ActiveSupport::TimeZone.rationalize_offset(-25200)).to eq(Rational(-7, 24))
    end
  end

  describe ".format_offset" do
    it "should correctly format an offset" do
      expect(::ActiveSupport::TimeZone.format_offset(-25200)).to eq("-07:00")
      expect(::ActiveSupport::TimeZone.format_offset(Rational(-4, 24), false)).to eq("-0400")
    end
  end

  describe ".parameterize_zone" do
    it "should return the parameterized version of the zone" do
      expect(::ActiveSupport::TimeZone.parameterize_zone(subject_zone.to_str)).to eq(subject_zone.to_str_parameterized)
      expect(::ActiveSupport::TimeZone.parameterize_zone(subject_zone.to_str)).to eq(subject_zone.to_str_parameterized)
      expect(::ActiveSupport::TimeZone.parameterize_zone(subject_zone.to_str, false)).to eq(subject_zone.to_str_parameterized(false))
      expect(::ActiveSupport::TimeZone.parameterize_zone("INVALID")).to eq("invalid")
    end
  end

  describe ".unparameterize_zone" do
    it "should return the parameterized version of the zone" do
      expect(::ActiveSupport::TimeZone.unparameterize_zone(subject_zone.to_str_parameterized)).to eq(subject_zone)
      expect(::ActiveSupport::TimeZone.unparameterize_zone(subject_zone.to_str_parameterized, true)).to eq(subject_zone.to_str)
      expect(::ActiveSupport::TimeZone.unparameterize_zone(subject_zone.to_str_with_dst_parameterized)).to eq(subject_zone)
      expect(::ActiveSupport::TimeZone.unparameterize_zone(subject_zone.to_str_with_dst_parameterized, true)).to eq(subject_zone.to_str_with_dst)
      expect(::ActiveSupport::TimeZone.unparameterize_zone("INVALID")).to eq(nil)
    end
  end

  describe ".find" do
    it "should find timezones" do
      expect(::ActiveSupport::TimeZone.find("(GMT-07:00) Mountain Time (US & Canada)")).to eq(subject_zone)
      expect(::ActiveSupport::TimeZone.find("(GMT-06:00) Mountain Time (US & Canada) (DST)")).to eq(subject_zone)
      expect(::ActiveSupport::TimeZone.find("(GMT-06:00) Mountain Time (US & Canada) Daylight Saving Time", "Daylight Saving Time")).to eq(subject_zone)
      expect(::ActiveSupport::TimeZone.find("INVALID", "INVALID")).to be_nil
    end
  end

  describe ".list_all" do
    it "should list all timezones" do
      expect(::ActiveSupport::TimeZone.list_all(false)).to eq(::ActiveSupport::TimeZone.all.map(&:to_s))
      expect(::ActiveSupport::TimeZone.list_all(true)).to include("(GMT-06:00) #{subject_zone.aliases.first} (DST)")
      expect(::ActiveSupport::TimeZone.list_all(true, "Daylight Saving Time")).to include("(GMT-06:00) #{subject_zone.aliases.first} Daylight Saving Time")
    end
  end

  describe "#offset" do
    it "should correctly return zone offset" do
      expect(subject_zone.offset).to eq(subject_zone.utc_offset)
    end
  end

  describe "#current_offset" do
    it "should correctly return current zone offset" do
      expect(subject_zone.current_offset(false, ::DateTime.civil(2012, 1, 15))).to eq(subject_zone.offset)
      expect(subject_zone.current_offset(true, ::DateTime.civil(2012, 7, 15))).to eq(subject_zone.dst_offset(true))
    end
  end

  describe "#current_alias" do
    it "should correctly return current zone alias or the first one" do
      zone = ActiveSupport::TimeZone["America/Halifax"]
      expect(zone.current_alias).to eq("America/Halifax")
      allow(zone.tzinfo).to receive(:identifier).and_return("INVALID")
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

  describe "#dst_period" do
    it "should correctly return zone offset" do
      expect(subject_zone.dst_period).to be_a(::TZInfo::TimezonePeriod)
      expect(subject_zone.dst_period(1000)).to be_nil
      expect(zone_without_dst.dst_period).to be_nil
    end
  end

  describe "#uses_dst?" do
    it "should correctly detect offset usage" do
      expect(subject_zone.uses_dst?).to be_true
      expect(subject_zone.uses_dst?(::DateTime.civil(2012, 7, 15))).to be_true
      expect(subject_zone.uses_dst?(::DateTime.civil(2012, 1, 15))).to be_false
      expect(subject_zone.uses_dst?(1000)).to be_false
      expect(zone_without_dst.uses_dst?).to be_false
    end
  end

  describe "#dst_name" do
    it "should correctly get zone name with Daylight Saving Time" do
      expect(subject_zone.dst_name).to eq("Mountain Time (US & Canada) (DST)")
      expect(subject_zone.dst_name("Daylight Saving Time")).to eq("Mountain Time (US & Canada) Daylight Saving Time")
      expect(subject_zone.dst_name(nil, 1000)).to be_nil
      expect(zone_without_dst.to_str_with_dst).to be_nil
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

  describe "#dst_offset" do
    it "should correctly return zone offset" do
      expect(subject_zone.dst_offset).to eq(subject_zone.dst_correction + subject_zone.utc_offset)
      expect(subject_zone.dst_offset(true)).to eq(::ActiveSupport::TimeZone.rationalize_offset(subject_zone.dst_correction + subject_zone.utc_offset))
      expect(zone_without_dst.dst_offset(false, 1000)).to eq(0)
      expect(zone_without_dst.dst_offset).to eq(0)
    end
  end

  describe "#to_str_with_dst" do
    it "should correctly format zone with Daylight Saving Time" do
      expect(subject_zone.to_str_with_dst).to eq("(GMT-06:00) #{subject_zone.current_alias} (DST)")
      expect(subject_zone.to_str_with_dst("Daylight Saving Time")).to eq("(GMT-06:00) #{subject_zone.current_alias} Daylight Saving Time")
      expect(subject_zone.to_str_with_dst("Daylight Saving Time", nil, "NAME")).to eq("(GMT-06:00) NAME Daylight Saving Time")
      expect(subject_zone.to_str_with_dst(nil, 1000)).to be_nil
      expect(zone_without_dst.to_str_with_dst).to be_nil
    end
  end

  describe "#to_str_parameterized" do
    it "should correctly format (parameterized) zone" do
      expect(subject_zone.to_str_parameterized).to eq(::ActiveSupport::TimeZone.parameterize_zone(subject_zone.to_str))
      expect(subject_zone.to_str_parameterized(false)).to eq(::ActiveSupport::TimeZone.parameterize_zone(subject_zone.to_str, false))
      expect(subject_zone.to_str_parameterized(false, "NAME SPACE")).to eq(::ActiveSupport::TimeZone.parameterize_zone("NAME SPACE", false))
    end
  end

  describe "#to_str_with_dst_parameterized" do
    it "should correctly format (parameterized) zone with Daylight Saving Time" do
      expect(subject_zone.to_str_with_dst_parameterized).to eq("-0600@mountain-time-us-canada-dst")
      expect(subject_zone.to_str_with_dst_parameterized("Daylight Saving Time")).to eq("-0600@mountain-time-us-canada-daylight-saving-time")
      expect(subject_zone.to_str_with_dst_parameterized(nil, 1000)).to be_nil
      expect(subject_zone.to_str_with_dst_parameterized("Daylight Saving Time", nil, "NAME SPACE")).to eq("-0600@name-space-daylight-saving-time")
      expect(zone_without_dst.to_str_with_dst_parameterized).to be_nil
    end
  end
end
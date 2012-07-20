# encoding: utf-8
#
# This file is part of the cowtech-extensions gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Cowtech::Extensions::DateTime do
  let(:random_reference) { ::DateTime.civil(1990 + rand(30), 1 + rand(10), 1 + rand(25), 1 + rand(20), 1 + rand(58), 1 + rand(58)).in_time_zone }
  let(:fixed_reference){ ::DateTime.civil(2005, 6, 7, 8, 9, 10, ::DateTime.rationalize_offset(25200)) }
  let(:reference_zone) { ::ActiveSupport::TimeZone["Mountain Time (US & Canada)"] }
  let(:zone_without_dst) { ::ActiveSupport::TimeZone["International Date Line West"] }

  before(:all) do
    ::Cowtech::Extensions.load!
  end

  describe ".days" do
    it "should return the list of the days of the week" do
      ::DateTime.days.should be_kind_of(::Array)
      ::DateTime.days[3].should == {:value => "4", :label => "Wed"}
      ::DateTime.days(false).should be_kind_of(::Array)
      ::DateTime.days(false)[3].should == {:value => "4", :label => "Wednesday"}

      ::Cowtech::Extensions.settings.setup_date_names(nil, nil, 7.times.collect {|i| (i + 1).to_s * 2}, 7.times.collect {|i| (i + 1).to_s})
      ::DateTime.days.should be_kind_of(::Array)
      ::DateTime.days[3].should == {:value => "4", :label => "4"}
      ::DateTime.days(false).should be_kind_of(::Array)
      ::DateTime.days(false)[3].should == {:value => "4", :label => "44"}
    end
  end

  describe ".months" do
    it "should return the list of the months of the year" do
      ::DateTime.months.should be_kind_of(::Array)
      ::DateTime.months[6].should == {:value => "07", :label => "Jul"}
      ::DateTime.months(false).should be_kind_of(::Array)
      ::DateTime.months(false)[6].should == {:value => "07", :label => "July"}

      ::Cowtech::Extensions.settings.setup_date_names(12.times.collect {|i| (i + 1).to_s * 2}, 12.times.collect {|i| (i + 1).to_s}, nil, nil)
      ::DateTime.months.should be_kind_of(::Array)
      ::DateTime.months[6].should == {:value => "07", :label => "7"}
      ::DateTime.months(false).should be_kind_of(::Array)
      ::DateTime.months(false)[6].should == {:value => "07", :label => "77"}
    end

  end

  describe ".years" do
    it "should return a range of years" do
      ::DateTime.years.should == (::Date.today.year - 10..::Date.today.year + 10).to_a
      ::DateTime.years(5).should == (::Date.today.year - 5..::Date.today.year + 5).to_a
      ::DateTime.years(5, true, nil, true).collect(&:value).should == (::Date.today.year - 5..::Date.today.year + 5).to_a
      ::DateTime.years(5, false).should == (::Date.today.year - 5..::Date.today.year).to_a
      ::DateTime.years(5, false, 1900).should == (1895..1900).to_a
    end
  end

  describe ".timezones" do
    it "should list all timezones" do ::DateTime.timezones.should == ::ActiveSupport::TimeZone.all end
  end

  describe ".list_timezones" do
    it "should forward to ActiveSupport::TimeZone" do
      ::ActiveSupport::TimeZone.should_receive(:list_all)
      ::DateTime.list_timezones
    end
  end

  describe ".find_timezone" do
    it "should forward to ActiveSupport::TimeZone" do
      ::ActiveSupport::TimeZone.should_receive(:find)
      ::DateTime.find_timezone(reference_zone.name)
    end
  end

  describe ".rationalize_offset" do
    it "should return the correct rational value" do
      ::ActiveSupport::TimeZone.should_receive(:rationalize_offset)
      ::DateTime.rationalize_offset(0)
    end
  end

  describe ".parameterize_zone" do
    it "should forward to ActiveSupport::TimeZone" do
      ::ActiveSupport::TimeZone.should_receive(:parameterize_zone)
      ::DateTime.parameterize_zone(reference_zone)
    end
  end

  describe ".unparameterize_zone" do
    it "should forward to ActiveSupport::TimeZone" do
      ::ActiveSupport::TimeZone.should_receive(:unparameterize_zone)
      ::DateTime.unparameterize_zone(reference_zone)
    end
  end

  describe ".easter" do
    it "should compute the valid Easter day" do
      {1984 => "0422", 1995 => "0416", 2006 => "0416", 2017 => "0416"}.each do |year, date|
        ::DateTime.easter(year).strftime("%Y%m%d").should == "#{year}#{date}"
      end
    end
  end

  describe ".custom_format" do
    it "should find the format" do
      ::DateTime.custom_format(:ct_date).should == "%Y-%m-%d"
      ::DateTime.custom_format("ct_date").should == "%Y-%m-%d"

      ::Cowtech::Extensions.settings.setup_date_formats({:ct_foo => "%ABC"})

      ::DateTime.custom_format(:ct_foo).should == "%ABC"
      ::DateTime.custom_format("ct_foo").should == "%ABC"
    end

    it "should return the key if format is not found" do ::DateTime.custom_format(:ct_unused) == "ct_unused" end
  end

  describe ".is_valid?" do
    it "should recognize a valid date" do
      ::DateTime.is_valid?("2012-04-05", "%F").should be_true
      ::DateTime.is_valid?("2012-04-05", :ct_date).should be_true
    end

    it "should fail if the argument or the format is not valid" do
      ::DateTime.is_valid?("ABC", "%F").should be_false
      ::DateTime.is_valid?("2012-04-05", "%X").should be_false
    end
  end

  describe "#utc_time" do
    it "should convert to UTC Time" do random_reference.utc_time.should be_a(::Time) end
  end

  describe "#in_months" do
    it "should return the amount of months passed since the start of the reference year" do
      ::Date.today.in_months.should == ::Date.today.month
      fixed_reference.in_months(2000).should == 66
    end
  end

  describe "#padded_month" do
    it "should pad the month number" do
      random_reference.padded_month.should == random_reference.month.to_s.rjust(2, "0")
      ::Date.civil(2000, 8, 8).padded_month.should == "08"
    end
  end

  describe "#lstrftime" do
    it "should return corrected formatted string" do
      fixed_reference.lstrftime(:db).should == "db"
      fixed_reference.lstrftime("%F").should == "2005-06-07"
      fixed_reference.lstrftime(:ct_iso_8601).should == "2005-06-07T08:09:10+0700"

      ::Cowtech::Extensions.settings.setup_date_names
      ::Cowtech::Extensions.settings.setup_date_formats({:ct_local_test => "%a %A %b %B %d %Y %H"})
      fixed_reference.lstrftime(:ct_local_test).should == "Tue Tuesday Jun June 07 2005 08"

      ::Cowtech::Extensions.settings.setup_date_names(
          12.times.collect {|i| (i + 1).to_s * 2}, 12.times.collect {|i| (i + 1).to_s},
          7.times.collect {|i| (i + 1).to_s * 2}, 7.times.collect {|i| (i + 1).to_s}
      )

      fixed_reference.lstrftime(:ct_local_test).should == "3 33 6 66 07 2005 08"
    end

    it "should fix Ruby 1.8 %z and %Z bug" do
      original_ruby_version = RUBY_VERSION
      ::Kernel::silence_warnings { Object.const_set("RUBY_VERSION", "1.9.3") }
      fixed_reference.lstrftime("%z").should == "+0700"
      fixed_reference.lstrftime("%:z").should == "+07:00"
      ::Kernel::silence_warnings { Object.const_set("RUBY_VERSION", original_ruby_version) }
    end
  end

  describe "#local_strftime" do
    it "should retrieve the date in the current timezone" do
      ::Time.zone = ::ActiveSupport::TimeZone[0]
      ::Cowtech::Extensions.settings.setup_date_formats({:ct_local_test => "%a %A %b %B %d %Y %H"})
      fixed_reference.local_strftime(:ct_local_test).should == "Tue Tuesday Jun June 07 2005 01"
    end
  end

  describe "#local_lstrftime" do
    it "should retrieve the date in the current timezone" do
      ::Time.zone = ::ActiveSupport::TimeZone[0]

      ::Cowtech::Extensions.settings.setup_date_names
      ::Cowtech::Extensions.settings.setup_date_formats({:ct_local_test => "%a %A %b %B %d %Y %H"})

      ::Cowtech::Extensions.settings.setup_date_names(
          12.times.collect {|i| (i + 1).to_s * 2}, 12.times.collect {|i| (i + 1).to_s},
          7.times.collect {|i| (i + 1).to_s * 2}, 7.times.collect {|i| (i + 1).to_s}
      )

      fixed_reference.local_lstrftime(:ct_local_test).should == "3 33 6 66 07 2005 01"
    end
  end
end

describe Cowtech::Extensions::TimeZone do
  let(:reference_zone) { ::ActiveSupport::TimeZone["Mountain Time (US & Canada)"] }
  let(:zone_without_dst) { ::ActiveSupport::TimeZone["International Date Line West"] }

  before(:all) do
    ::Cowtech::Extensions.load!
  end

  describe ".rationalize_offset" do
    it "should return the correct rational value" do
      ::ActiveSupport::TimeZone.rationalize_offset(::ActiveSupport::TimeZone[4]).should == Rational(1, 6)
      ::ActiveSupport::TimeZone.rationalize_offset(-25200).should == Rational(-7, 24)
    end
  end

  describe ".format_offset" do
    it "should correctly format an offset" do
      ::ActiveSupport::TimeZone.format_offset(-25200).should == "-07:00"
      ::ActiveSupport::TimeZone.format_offset(Rational(-4, 24), false).should == "-0400"
    end
  end

  describe ".parameterize_zone" do
    it "should return the parameterized version of the zone" do
      ::ActiveSupport::TimeZone.parameterize_zone(reference_zone).should == reference_zone.to_s_parameterized
      ::ActiveSupport::TimeZone.parameterize_zone(reference_zone).should == reference_zone.to_s_parameterized
      ::ActiveSupport::TimeZone.parameterize_zone(reference_zone, false).should == reference_zone.to_s_parameterized(false)
      ::ActiveSupport::TimeZone.parameterize_zone("INVALID").should == "invalid"
    end
  end

  describe ".unparameterize_zone" do
    it "should return the parameterized version of the zone" do
      ::ActiveSupport::TimeZone.unparameterize_zone(reference_zone.to_s_parameterized).should == reference_zone
      ::ActiveSupport::TimeZone.unparameterize_zone(reference_zone.to_s_parameterized, true).should == reference_zone.to_s
      ::ActiveSupport::TimeZone.unparameterize_zone(reference_zone.to_s_with_dst_parameterized).should == reference_zone
      ::ActiveSupport::TimeZone.unparameterize_zone(reference_zone.to_s_with_dst_parameterized, true).should == reference_zone.to_s_with_dst
      ::ActiveSupport::TimeZone.unparameterize_zone("INVALID").should == nil
    end
  end

  describe ".find" do
    it "should find timezones" do
      ::ActiveSupport::TimeZone.find("(GMT-07:00) Mountain Time (US & Canada)").should == reference_zone
      ::ActiveSupport::TimeZone.find("(GMT-06:00) Mountain Time (US & Canada) (Daylight Saving Time)").should == reference_zone
      ::ActiveSupport::TimeZone.find("(GMT-06:00) Mountain Time (US & Canada) DST", "DST").should == reference_zone
      ::ActiveSupport::TimeZone.find("INVALID", "INVALID").should be_nil
    end
  end

  describe ".list_all" do
    it "should list all timezones" do
      ::ActiveSupport::TimeZone.list_all(false).should == ::ActiveSupport::TimeZone.all.collect(&:to_s)
      ::ActiveSupport::TimeZone.list_all(true).should include("(GMT-06:00) Mountain Time (US & Canada) (Daylight Saving Time)")
      ::ActiveSupport::TimeZone.list_all(true, "DST").should include("(GMT-06:00) Mountain Time (US & Canada) DST")
    end
  end

  describe "#offset" do
    it "should correctly return zone offset" do
      reference_zone.offset.should == reference_zone.utc_offset
    end
  end

  describe "#current_offset" do
    it "should correctly return current zone offset" do
      reference_zone.current_offset(false, ::DateTime.civil(2012, 1, 15)).should == reference_zone.offset
      reference_zone.current_offset(true, ::DateTime.civil(2012, 7, 15)).should == reference_zone.dst_offset(true)
    end
  end

  describe "#dst_period" do
    it "should correctly return zone offset" do
      reference_zone.dst_period.should be_a(::TZInfo::TimezonePeriod)
      reference_zone.dst_period(1000).should be_nil
      zone_without_dst.dst_period.should be_nil
    end
  end

  describe "#uses_dst?" do
    it "should correctly detect offset usage" do
      reference_zone.uses_dst?.should be_true
      reference_zone.uses_dst?(1000).should be_false
      zone_without_dst.uses_dst?.should be_false
    end
  end

  describe "#dst_name" do
    it "should correctly get zone name with DST" do
      reference_zone.dst_name.should == "Mountain Time (US & Canada) (Daylight Saving Time)"
      reference_zone.dst_name("DST").should == "Mountain Time (US & Canada) DST"
      reference_zone.dst_name(nil, 1000).should be_nil
      zone_without_dst.to_s_with_dst.should be_nil
    end
  end

  describe "#dst_correction" do
    it "should correctly detect offset usage" do
      reference_zone.dst_correction.should == 3600
      reference_zone.dst_correction(true).should == Rational(1, 24)
      reference_zone.dst_correction(false, 1000).should == 0
      zone_without_dst.dst_correction.should == 0
    end
  end

  describe "#dst_offset" do
    it "should correctly return zone offset" do
      reference_zone.dst_offset.should == reference_zone.dst_correction + reference_zone.utc_offset
      reference_zone.dst_offset(true).should == ::ActiveSupport::TimeZone.rationalize_offset(reference_zone.dst_correction + reference_zone.utc_offset)
      zone_without_dst.dst_offset(false, 1000).should == 0
      zone_without_dst.dst_offset.should == 0
    end
  end

  describe "#to_s_with_dst" do
    it "should correctly format zone with DST" do
      reference_zone.to_s_with_dst.should == "(GMT-06:00) Mountain Time (US & Canada) (Daylight Saving Time)"
      reference_zone.to_s_with_dst("DST").should == "(GMT-06:00) Mountain Time (US & Canada) DST"
      reference_zone.to_s_with_dst(nil, 1000).should be_nil
      zone_without_dst.to_s_with_dst.should be_nil
    end
  end

  describe "#to_s_parameterized" do
    it "should correctly format (parameterized) zone" do
      reference_zone.to_s_parameterized.should == ::ActiveSupport::TimeZone.parameterize_zone(reference_zone)
      reference_zone.to_s_parameterized(false).should == ::ActiveSupport::TimeZone.parameterize_zone(reference_zone, false)
    end
  end

  describe "#to_s_with_dst_parameterized" do
    it "should correctly format (parameterized) zone with DST" do
      reference_zone.to_s_with_dst_parameterized.should == "-0600@mountain-time-us-canada-daylight-saving-time"
      reference_zone.to_s_with_dst_parameterized("DST").should == "-0600@mountain-time-us-canada-dst"
      reference_zone.to_s_with_dst_parameterized(nil, false, 1000).should be_nil
      zone_without_dst.to_s_with_dst_parameterized.should be_nil
    end
  end
end
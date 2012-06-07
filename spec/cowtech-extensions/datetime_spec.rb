# encoding: utf-8
#
# This file is part of the cowtech-extensions gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Cowtech::Extensions::DateTime do
  let(:random_reference) { DateTime.civil(1990 + rand(30), 1 + rand(10), 1 + rand(25), 1 + rand(20), 1 + rand(58), 1 + rand(58)).in_time_zone }
  let(:fixed_reference){
    tz = ActiveSupport::TimeZone[7]
    date = DateTime.civil(2005, 6, 7, 8, 9, 10, DateTime.rational_offset(tz))
  }

  describe "#days" do
    it "should return the list of the days of the week" do
      DateTime.days.should be_kind_of(Array)
      DateTime.days[3].should == {:value => "4", :label => "Wed"}
      DateTime.days(false).should be_kind_of(Array)
      DateTime.days(false)[3].should == {:value => "4", :label => "Wednesday"}

      Cowtech::Extensions.settings.setup_date_names(nil, nil, 7.times.collect {|i| (i + 1).to_s * 2}, 7.times.collect {|i| (i + 1).to_s})
      DateTime.days.should be_kind_of(Array)
      DateTime.days[3].should == {:value => "4", :label => "4"}
      DateTime.days(false).should be_kind_of(Array)
      DateTime.days(false)[3].should == {:value => "4", :label => "44"}
    end
  end

  describe "#months" do
    it "should return the list of the months of the year" do
      DateTime.months.should be_kind_of(Array)
      DateTime.months[6].should == {:value => "07", :label => "Jul"}
      DateTime.months(false).should be_kind_of(Array)
      DateTime.months(false)[6].should == {:value => "07", :label => "July"}

      Cowtech::Extensions.settings.setup_date_names(12.times.collect {|i| (i + 1).to_s * 2}, 12.times.collect {|i| (i + 1).to_s}, nil, nil)
      DateTime.months.should be_kind_of(Array)
      DateTime.months[6].should == {:value => "07", :label => "7"}
      DateTime.months(false).should be_kind_of(Array)
      DateTime.months(false)[6].should == {:value => "07", :label => "77"}
    end

  end

  describe "#years" do
    it "should return a range of years" do
      DateTime.years.collect(&:value).should == (Date.today.year - 10..Date.today.year + 10).to_a
      DateTime.years(5).collect(&:value).should == (Date.today.year - 5..Date.today.year + 5).to_a
      DateTime.years(5, false).collect(&:value).should == (Date.today.year - 5..Date.today.year).to_a
      DateTime.years(5, false, Date.civil(1900, 1, 1)).collect(&:value).should == (1895..1900).to_a
    end
  end

  describe "#easter" do
    it "should compute the valid Easter day" do
      {1984 => "0422", 1995 => "0416", 2006 => "0416", 2017 => "0416"}.each do |year, date|
        DateTime.easter(year).strftime("%Y%m%d").should == "#{year}#{date}"
      end
    end
  end

  describe "#custom_format" do
    it "should find the format" do
      DateTime.custom_format(:ct_date).should == "%Y-%m-%d"
      DateTime.custom_format("ct_date").should == "%Y-%m-%d"

      Cowtech::Extensions.settings.setup_date_formats({:ct_foo => "%ABC"})

      DateTime.custom_format(:ct_foo).should == "%ABC"
      DateTime.custom_format("ct_foo").should == "%ABC"
    end

    it "should return the key if format is not found" do DateTime.custom_format(:ct_unused) == "ct_unused" end
  end

  describe "#is_valid?" do
    it "should recognize a valid date" do
      DateTime.is_valid?("2012-04-05", "%F").should be_true
      DateTime.is_valid?("2012-04-05", :ct_date).should be_true
    end

    it "should fail if the argument or the format is not valid" do
      DateTime.is_valid?("ABC", "%F").should be_false
      DateTime.is_valid?("2012-04-05", "%X").should be_false
    end
  end

  describe "#rational_offset" do
    it "should return the correct rational value" do
      DateTime.rational_offset(ActiveSupport::TimeZone[4]).should == Rational(4, 24)
      DateTime.rational_offset(ActiveSupport::TimeZone[-7]).should == Rational(-7, 24)
    end
  end

  describe "#utc_time" do
    it "should convert to UTC Time" do random_reference.utc_time.should be_kind_of(Time) end
  end

  describe "#in_months" do
    it "should return the amount of months passed since the start of the reference year" do
      Date.today.in_months.should == Date.today.month
      fixed_reference.in_months(2000).should == 66
    end
  end

  describe "#padded_month" do
    it "should pad the month number" do
      random_reference.padded_month.should == random_reference.month.to_s.rjust(2, "0")
      Date.civil(2000, 8, 8).padded_month.should == "08"
    end
  end

  describe "#lstrftime" do
    it "should return corrected formatted string" do
      fixed_reference.lstrftime(:db).should == "db"
      fixed_reference.lstrftime("%F").should == "2005-06-07"
      fixed_reference.lstrftime(:ct_iso_8601).should == "2005-06-07T08:09:10+0700"

      Cowtech::Extensions.settings.setup_date_names
      Cowtech::Extensions.settings.setup_date_formats({:ct_local_test => "%a %A %b %B %d %Y %H"})
      fixed_reference.lstrftime(:ct_local_test).should == "Tue Tuesday Jun June 07 2005 08"

      Cowtech::Extensions.settings.setup_date_names(
          12.times.collect {|i| (i + 1).to_s * 2}, 12.times.collect {|i| (i + 1).to_s},
          7.times.collect {|i| (i + 1).to_s * 2}, 7.times.collect {|i| (i + 1).to_s}
      )

      fixed_reference.lstrftime(:ct_local_test).should == "3 33 6 66 07 2005 08"
      end
  end

  describe "#local_strftime" do
    it "should retrieve the date in the current timezone" do
      ::Time.zone = ActiveSupport::TimeZone[0]
      Cowtech::Extensions.settings.setup_date_formats({:ct_local_test => "%a %A %b %B %d %Y %H"})
      fixed_reference.local_strftime(:ct_local_test).should == "Tue Tuesday Jun June 07 2005 01"
    end
  end

  describe "#local_lstrftime" do
    it "should retrieve the date in the current timezone" do
      ::Time.zone = ActiveSupport::TimeZone[0]

      Cowtech::Extensions.settings.setup_date_names
      Cowtech::Extensions.settings.setup_date_formats({:ct_local_test => "%a %A %b %B %d %Y %H"})

      Cowtech::Extensions.settings.setup_date_names(
          12.times.collect {|i| (i + 1).to_s * 2}, 12.times.collect {|i| (i + 1).to_s},
          7.times.collect {|i| (i + 1).to_s * 2}, 7.times.collect {|i| (i + 1).to_s}
      )

      fixed_reference.local_lstrftime(:ct_local_test).should == "3 33 6 66 07 2005 01"
    end
  end
end
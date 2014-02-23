# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Lazier::Configuration do
  class ConfigurationSpecSample < ::Lazier::Configuration
    property :readwrite, default: "1"
    property :required, required: true
    property :readonly, default: "2", readonly: true
  end

  describe "#property" do
    it "should correctly define property and get it defaults" do
      expect(ConfigurationSpecSample.new(required: 1).readwrite).to eq("1")
      expect(ConfigurationSpecSample.new(required: 1, readwrite: "3").readwrite).to eq("3")
      expect(ConfigurationSpecSample.new(required: 1).readonly).to eq("2")
      expect(ConfigurationSpecSample.new(required: 1, readonly: "4").readonly).to eq("4")
    end

    it "should not allow writing readonly properties" do
      subject = ConfigurationSpecSample.new(required: 1)

      expect { subject .readonly = "4" }.to raise_error(ArgumentError)
      expect(subject .readonly).to eq("2")
    end

    it "should blow up for require properties" do
      expect { ConfigurationSpecSample.new }.to raise_error(ArgumentError)
    end
  end
end

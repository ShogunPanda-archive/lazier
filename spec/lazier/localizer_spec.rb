# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Lazier::Localizer do
  describe "#initialize" do
    it "should call i18n_setup and then i18n=" do
      expect_any_instance_of(::Lazier::Localizer).to receive(:i18n_setup).with("ROOT", "PATH")
      expect_any_instance_of(::Lazier::Localizer).to receive(:i18n=).with(:it)
      ::Lazier::Localizer.new("ROOT", "PATH", :it)
    end

    it "should setup default arguments" do
      expect_any_instance_of(::Lazier::Localizer).to receive(:i18n_setup).with(:lazier, ::File.absolute_path(::Pathname.new(::File.dirname(__FILE__)).to_s + "/../../locales/"))
      expect_any_instance_of(::Lazier::Localizer).to receive(:i18n=).with(nil)
      ::Lazier::Localizer.new
    end
  end

  describe ".localize" do
    it "should create a new localizer and forward the message" do
      obj = ::Object.new
      expect(obj).to receive(:string).with("ARGUMENT")

      expect(::Lazier::Localizer).to receive(:new).and_call_original
      expect_any_instance_of(::Lazier::Localizer).to receive(:i18n).and_return(obj)
      ::Lazier::Localizer.localize(:string, "ARGUMENT")
    end
  end

  describe ".localize_on_locale" do
    it "should create a new localizer and forward the message" do
      obj = ::Object.new
      expect(obj).to receive(:string).with("ARGUMENT")

      expect(::Lazier::Localizer).to receive(:new).with(nil, nil, :it).and_call_original
      expect_any_instance_of(::Lazier::Localizer).to receive(:i18n).and_return(obj)
      ::Lazier::Localizer.localize_on_locale(:it, :string, "ARGUMENT")
    end
  end
end
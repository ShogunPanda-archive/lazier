# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Lazier::Localizer do
  describe "#initialize" do
    it "should call i18n_setup and then i18n=" do
      ::Lazier::Localizer.any_instance.should_receive(:i18n_setup).with("ROOT", "PATH")
      ::Lazier::Localizer.any_instance.should_receive(:i18n=).with(:it)
      Lazier::Localizer.new("ROOT", "PATH", :it)
    end

    it "should setup default arguments" do
      ::Lazier::Localizer.any_instance.should_receive(:i18n_setup).with(:lazier, ::File.absolute_path(::Pathname.new(::File.dirname(__FILE__)).to_s + "/../../locales/"))
      ::Lazier::Localizer.any_instance.should_receive(:i18n=).with(nil)
      Lazier::Localizer.new
    end
  end

  describe ".localize" do
    it "should create a new localizer and forward the message" do
      obj = Object.new
      obj.should_receive(:string).with("ARGUMENT")
      ::Lazier::Localizer.should_receive(:new).and_call_original
      ::Lazier::Localizer.any_instance.should_receive(:i18n).and_return(obj)
      ::Lazier::Localizer.localize(:string, "ARGUMENT")
    end
  end

  describe ".localize" do
    it "should create a new localizer and forward the message" do
      obj = Object.new
      obj.should_receive(:string).with("ARGUMENT")
      ::Lazier::Localizer.should_receive(:new).with(nil, nil, :it).and_call_original
      ::Lazier::Localizer.any_instance.should_receive(:i18n).and_return(obj)
      ::Lazier::Localizer.localize_on_locale(:it, :string, "ARGUMENT")
    end
  end
end
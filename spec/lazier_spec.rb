# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Lazier do
  describe ".load!" do
    describe "should load all extensions by default" do
      ::Lazier.load!

      it "for Boolean" do
        expect(true).to respond_to("value")
        expect(true).to respond_to("to_i")
      end

      it "for DateTime" do
        expect(::DateTime).to respond_to("custom_format")
        expect(::DateTime.now).to respond_to("lstrftime")
      end

      it "for Hash" do
        expect({a: "b"}).to respond_to("a")
      end

      it "for Math" do
        expect(::Math).to respond_to("min")
      end

      it "for Object" do
        expect(0).to respond_to("debug_dump")
      end

      it "for Pathname" do
        expect(::Pathname.new($0)).to respond_to("components")
      end

      it "for String" do
        expect("").to respond_to("remove_accents")
      end
    end
  end

  describe ".i18n" do
    it "should run localize if needed" do
      Lazier.instance_variable_set(:@i18n_locales_path, nil)
      Lazier.should_receive(:localize)
      Lazier.i18n
    end

    it "should return a localizer object" do
      R18n.stub(:get).and_return(Object.new)
      R18n.get.should_receive(:try).with(:t)
      Lazier.i18n
    end
  end

  describe ".localize" do
    it "should set the right locale path" do
      Lazier.localize
      expect(Lazier.instance_variable_get(:@i18n_locales_path)).to eq(File.absolute_path(::Pathname.new(File.dirname(__FILE__)).to_s + "/../locales/"))
    end

    it "should set using English if called without arguments" do
      R18n.should_receive(:set).with(:en, File.absolute_path(::Pathname.new(File.dirname(__FILE__)).to_s + "/../locales/"))
      Lazier.localize
    end

    it "should set the requested locale" do
      R18n.should_receive(:set).with(:it, File.absolute_path(::Pathname.new(File.dirname(__FILE__)).to_s + "/../locales/"))
      Lazier.localize(:it)
    end
  end

  describe ".localize?" do
    it "should respect the value of the internal variable" do
      Lazier.instance_variable_set(:@i18n_locales_path, nil)
      expect(Lazier.localized?).to be_false
      Lazier.localize(:en)
      expect(Lazier.localized?).to be_true
    end
  end
end
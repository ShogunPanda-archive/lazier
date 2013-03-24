# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Lazier do
  describe ".load!" do
    describe "should load all extensions by default" do
      ENV["LANG"] = "en"
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

  describe ".find_class" do
    module LazierTest
      class TestClass

      end
    end

    it "should return a valid class" do
      expect(::Lazier.find_class("String")).to eq(String)
      expect(::Lazier.find_class("TestClass", "::LazierTest::%CLASS%")).to eq(::LazierTest::TestClass)
    end

    it "should raise an exception if the class is not found" do
      expect { ::Lazier.find_class(:invalid) }.to raise_error(::NameError)
    end

    it "should not expand engine scope if the class starts with ::" do
      expect { ::Lazier.find_class("::TestClass", "::LazierTest::%CLASS%") }.to raise_error(::NameError)
    end

    it "should only use scope if requested to" do
      expect { ::Lazier.find_class("::Fixnum", "::LazierTest::%CLASS%", true) }.to raise_error(::NameError)
    end

    it "should return anything but string or symbol as their class" do
      expect(::Lazier.find_class(nil)).to eq(NilClass)
      expect(::Lazier.find_class(1)).to eq(Fixnum)
      expect(::Lazier.find_class(["A"])).to eq(Array)
      expect(::Lazier.find_class({a: "b"})).to eq(Hash)
      expect(::Lazier.find_class(Hash)).to eq(Hash)
    end
  end
end
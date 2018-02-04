#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

require "spec_helper"

describe Lazier do
  describe ".load!" do
    describe "should load all extensions by default" do
      ::Lazier.load!

      it "for Boolean" do
        expect(true).to respond_to(:value)
        expect(true).to respond_to(:to_i)
      end

      it "for DateTime" do
        expect(::DateTime).to respond_to(:custom_format)
        expect(::DateTime.now).to respond_to(:format)
      end

      it "for Hash" do
        expect({a: "b"}).to respond_to(:ensure_access)
      end

      it "for Math" do
        expect(::Math).to respond_to(:min)
      end

      it "for Object" do
        expect(0).to respond_to(:to_debug)
      end

      it "for Pathname" do
        expect(::Pathname.new($0)).to respond_to(:components)
      end

      it "for String" do
        expect("").to respond_to(:ensure_valid_utf8)
      end
    end
  end

  describe ".loaded" do
    it "should return the list of loaded modules" do
      expect(Lazier.loaded_modules).to eq([:boolean, :object, :string, :hash, :datetime, :math, :pathname])
    end
  end

  describe ".modules_loaded?" do
    it "should return true if all specified modules are loaded" do
      expect(Lazier.modules_loaded?(:boolean)).to be_truthy
      expect(Lazier.modules_loaded?(:boolean, [:string, "object"])).to be_truthy
      expect(Lazier.modules_loaded?(:boolean, :foo)).to be_falsey
    end
  end

  describe ".find_class" do
    before(:each) do
      stub_const("::LazierTest::TestClass", Class.new)
    end

    it "should return a valid class" do
      expect(::Lazier.find_class("String")).to eq(String)
      expect(::Lazier.find_class("TestClass", "::LazierTest::%CLASS%")).to eq(::LazierTest::TestClass)
      expect(::Lazier.find_class("TestClass", "::LazierTest::@")).to eq(::LazierTest::TestClass)
      expect(::Lazier.find_class("TestClass", "::LazierTest::$")).to eq(::LazierTest::TestClass)
      expect(::Lazier.find_class("TestClass", "::LazierTest::?")).to eq(::LazierTest::TestClass)
      expect(::Lazier.find_class("TestClass", "::LazierTest::%")).to eq(::LazierTest::TestClass)
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

  describe ".benchmark" do
    it "should execute the given block" do
      control = ""
      Lazier.benchmark { control = "OK" }
      expect(control).to eq("OK")
    end

    it "without a message should return the elapsed time" do
      expect(Lazier.benchmark { "OK" }).to be_a(Float)
    end

    it "with a message should embed the elapsed time into the given message" do
      expect(Lazier.benchmark(message: "MESSAGE") { "OK" }).to match(/^MESSAGE \(\d+ ms\)$/)
      expect(Lazier.benchmark(message: "MESSAGE", precision: 2) { "OK" }).to match(/^MESSAGE \(\d+\.\d+ ms\)$/)
    end
  end

  describe ".platform" do
    it "should detect the right platform" do
      stub_const("RUBY_PLATFORM", "cygwin")
      expect(Lazier.platform(true)).to eq(:win32)

      stub_const("RUBY_PLATFORM", "darwin")
      expect(Lazier.platform(true)).to eq(:osx)

      stub_const("RUBY_PLATFORM", "java")
      expect(Lazier.platform(true)).to eq(:java)

      stub_const("RUBY_PLATFORM", "whatever")
      expect(Lazier.platform(true)).to eq(:posix)

      stub_const("RUBY_PLATFORM", "osx")
      expect(Lazier.platform).to eq(:posix)
    end
  end
end
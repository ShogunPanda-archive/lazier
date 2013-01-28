# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Lazier do
  describe ".is_ruby_18?" do
    it "it return true for Ruby 1.8" do
      original_ruby_version = RUBY_VERSION

      ::Kernel::silence_warnings { Object.const_set("RUBY_VERSION", "1.8.7") }
      expect(::Lazier.is_ruby_18?).to be_true
      ::Kernel::silence_warnings { Object.const_set("RUBY_VERSION", original_ruby_version) }
    end

    it "it return false otherwise" do
      original_ruby_version = RUBY_VERSION

      ::Kernel::silence_warnings { Object.const_set("RUBY_VERSION", "1.9.3") }
      expect(::Lazier.is_ruby_18?).to be_false
      ::Kernel::silence_warnings { Object.const_set("RUBY_VERSION", original_ruby_version) }
    end
  end

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
end
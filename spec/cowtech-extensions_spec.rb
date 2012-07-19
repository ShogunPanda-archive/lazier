require "spec_helper"

describe Cowtech::Extensions do
  describe ".is_ruby_18?" do
    it "it return true for Ruby 1.8" do
      original_ruby_version = RUBY_VERSION

      Kernel::silence_warnings { Object.const_set("RUBY_VERSION", "1.8.7") }
      Cowtech::Extensions.is_ruby_18?.should be_true
      Kernel::silence_warnings { Object.const_set("RUBY_VERSION", original_ruby_version) }
    end

    it "it return false otherwise" do
      original_ruby_version = RUBY_VERSION

      Kernel::silence_warnings { Object.const_set("RUBY_VERSION", "1.9.3") }
      Cowtech::Extensions.is_ruby_18?.should be_false
      Kernel::silence_warnings { Object.const_set("RUBY_VERSION", original_ruby_version) }
    end
  end

  describe ".load!" do
    describe "should load all extensions by default" do
      Cowtech::Extensions.load!

      it "for Boolean" do
        true.should respond_to("value")
        true.should respond_to("to_i")
      end

      it "for DateTime" do
        DateTime.should respond_to("custom_format")
        DateTime.now.should respond_to("lstrftime")
      end

      it "for Hash" do {:a => "b"}.should respond_to("a") end

      it "for Math" do Math.should respond_to("min") end

      it "for Object" do 0.should respond_to("debug_dump") end

      it "for Pathname" do Pathname.new($0).should respond_to("components") end

      it "for String" do "".should respond_to("remove_accents") end
    end

    describe "should load only required extensions" do
      Cowtech::Extensions.load!("boolean")

      it "for Boolean" do
        true.should respond_to("value")
        true.should respond_to("to_i")
      end

      it "for String" do "".should respond_to("remove_accents") end
    end
  end
end
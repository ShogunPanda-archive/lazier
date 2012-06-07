require "spec_helper"

describe Cowtech::Extensions do
  describe "#load! should load extensions" do
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
end
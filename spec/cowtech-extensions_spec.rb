require "spec_helper"

describe Cowtech::Extensions do
  describe "#load!" do
    it "should load the extensions" do
      Cowtech::Extensions.load!
    end
  end
end
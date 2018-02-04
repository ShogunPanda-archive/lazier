#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

require "spec_helper"

describe Lazier::Pathname do
  subject { ::Pathname.new($0) }

  before(:all) do
    ::Lazier.load!(:pathname)
  end

  describe "#components" do
    it "should return the components of the path" do
      expect([""] + subject.components).to eq(subject.to_s.split("/"))
    end
  end
end
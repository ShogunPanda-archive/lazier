# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Lazier::Pathname do
  subject { ::Pathname.new($0) }

  before(:all) do
    ::Lazier.load!
  end

  describe "#components" do
    it "should return the components of the path" do
      expect([""] + subject.components).to eq(subject.to_s.split("/"))
    end
  end
end
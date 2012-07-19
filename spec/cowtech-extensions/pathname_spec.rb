# encoding: utf-8
#
# This file is part of the cowtech-extensions gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Cowtech::Extensions::Pathname do
  let(:reference) { ::Pathname.new($0) }

  before(:all) do
    ::Cowtech::Extensions.load!
  end

  describe "#components" do
    it "should return the components of the path" do ([""] + reference.components).should == reference.to_s.split("/") end
  end
end
# encoding: utf-8
#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

class Container
  include Lazier::I18n
end

describe Lazier::I18n do
  let(:object) { Container.new }

  describe "#i18n_setup" do
    it "should set the root and the path" do
      object.i18n_setup("ROOT", "PATH")
      expect(object.instance_variable_get(:@i18n_root)).to eq(:ROOT)
      expect(object.instance_variable_get(:@i18n_locales_path)).to eq("PATH")
    end
  end

  describe "#i18n" do
    it "should call the private method if nothing is set" do
      object.instance_variable_set(:@i18n, nil)
      object.should_receive(:i18n_load_locale)
      object.i18n
    end
  end

  describe "#i18n=" do
    it "should call the private method if nothing is set" do
      object.should_receive(:i18n_load_locale).and_return("LOCALE")
      object.i18n = :en
      expect(object.instance_variable_get(:@i18n)).to eq("LOCALE")
    end

  end

  describe "#i18n_load_locale" do
    it "should set using system locale if called without arguments" do
      object.i18n_setup("ROOT", "PATH")
      R18n::I18n.should_receive(:new).with([ENV["LANG"], R18n::I18n.system_locale].compact, "PATH").and_call_original
      object.i18n = nil
    end

    it "should set the requested locale" do
      object.i18n_setup("ROOT", "PATH")
      R18n::I18n.should_receive(:new).with([:it, ENV["LANG"], R18n::I18n.system_locale].compact, "PATH").and_call_original
      object.i18n = :it
    end

    it "should call the root" do
      Lazier.load!
      t = Object.new
      object.i18n_setup("ROOT", ::File.absolute_path(::Pathname.new(::File.dirname(__FILE__)).to_s + "/../../locales/"))
      R18n::I18n.any_instance.should_receive(:t).and_return(t)
      t.should_receive("ROOT")
      object.i18n = :it
    end
  end
end

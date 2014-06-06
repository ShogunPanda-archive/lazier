#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Lazier::I18n do
  before(:all) do
    Lazier::I18n.default_locale = :en
  end

  before(:each) do |example|
    unless example.metadata[:skip_locale_whitelist]
      allow(::I18n).to receive("locale=")
      Lazier::I18n.default_locale = nil
    else
      Lazier::I18n.default_locale = :en
    end
  end

  subject! { Lazier::I18n.instance(force: true) }

  describe ".instance" do
    it "should return the singleton instance" do
      expect(subject).to be_a(Lazier::I18n)
      expect(Lazier::I18n.instance).to be(subject)
    end

    it "should return a new instance" do
      another = Lazier::I18n.instance(force: true)
      expect(another).not_to be(subject)
    end
  end

  describe "#initialize" do
    it "should save attributes" do
      subject = Lazier::I18n.new("it", root: "foo", path: "/dev/abc/..")
      expect(subject.locale).to eq(:it)
      expect(subject.root).to eq(:foo)
      expect(subject.path).to eq("/dev")
    end

    it "should fallback to the default locale" do
      Lazier::I18n.default_locale = "pt"
      expect(Lazier::I18n.new.locale).to eq(:pt)
    end

    describe "should fallback to the system locale" do
      it "in JRuby" do
        expect(Lazier).to receive(:platform).exactly(2).and_return(:java)

        if RUBY_PLATFORM !~ /java/
          stub_const("Java", Object.new)
          allow(Java).to receive(:java).and_return(Object.new)
          allow(Java.java).to receive(:util).and_return(Object.new)
          allow(Java.java.util).to receive(:Locale).and_return(Object.new)
          allow(Java.java.util.Locale).to receive(:getDefault).and_return(Object.new)
        end

        allow(Java.java.util.Locale.getDefault).to receive(:toString).and_return("jp")

        expect(Lazier::I18n.new.locale).to eq(:jp)
      end

      it "in OSX" do
        allow_any_instance_of(Lazier::I18n).to receive(:`).with("defaults read .GlobalPreferences AppleLanguages | awk 'NR==2{gsub(/[ ,]/, \"\");print}'").and_return("in")

        expect(Lazier).to receive(:platform).exactly(2).and_return(:osx)
        expect(Lazier::I18n.new.locale).to eq(:in)
      end

      it "in UNIX" do
        old_env = ENV["LANG"]

        ENV["LANG"] = "it"
        expect(Lazier).to receive(:platform).exactly(2).and_return(:posix)
        expect(Lazier::I18n.new.locale).to eq(:it)
        ENV["LANG"] = old_env
      end

      it "falling back to English" do
        expect(Lazier).to receive(:platform).and_return(:other)

        expect(Lazier::I18n.new.locale).to eq(:en)
      end
    end

    it "should setup the backend" do
      open("/tmp/it.yml", "w") {|f| f.write("---\nit:\n  lazier:") }
      subject = Lazier::I18n.new("it", path: "/tmp")

      expect(::I18n.enforce_available_locales).to be_truthy
      expect(::I18n.load_path).to include("/tmp/it.yml")
      expect(::I18n.exception_handler).to be_a(::Lazier::Exceptions::TranslationExceptionHandler)
      expect(subject.backend).to be_a(::I18n::Backend::Simple)
      File.unlink("/tmp/it.yml")
      ::I18n.load_path.delete("/tmp/it.yml")
    end
  end

  describe "#reload" do
    it "should reload translations" do
      expect_any_instance_of(::I18n::Backend::Simple).to receive(:load_translations).and_call_original
      subject.reload
    end
  end

  describe "#translations" do
    it "should return the list of translations" do
      subject.reload
      expect(subject.translations.keys).to eq([:lazier])
    end
  end

  describe "#locale=" do
    it "should assign the new locale" do
      expect(::I18n).to receive("locale=").with(:it)
      subject.locale = "it"
      expect(subject.locale).to eq(:it)
    end
  end

  describe "#locales" do
    it "should return the list of locales" do
      expect(subject.locales).to eq([:en, :it])
    end
  end

  describe "#translate" do
    it "should return the translation" do
      expect(subject.translate("configuration.not_defined", name: "foo", class: "bar")).to eq("Property foo is not defined for bar.")
      expect(subject.translate(".date.formats")).to eq({:default=>"%Y-%m-%d", :short=>"%b %d", :long=>"%B %d, %Y"})
      expect { subject.translate("::configuration.not_defined", property_name: "foo", class: "bar") }.to raise_error(Lazier::Exceptions::MissingTranslation)
    end
  end

  describe "#translate_in_locale" do
    it "should return the translation in the desired locale", skip_locale_whitelist: true do
      expect(subject.translate_in_locale(:it, "configuration.not_defined", name: "foo", class: "bar")).to eq("La proprietà foo non è definita per bar.")
    end
  end

  describe "#with_locale" do
    it "should execute a block with the new locale and then set the old locale back", skip_locale_whitelist: true do
      new_locale = nil

      subject.with_locale(:it) do
        new_locale = subject.locale
      end

      expect(new_locale).to eq(:it)
      expect(subject.locale).to eq(:en)
    end

    it "should raise exception after having restored the old locale", skip_locale_whitelist: true do
      new_locale = nil

      expect {
        subject.with_locale(:it) do
          new_locale = subject.locale
          raise RuntimeError
        end
      }.to raise_error(RuntimeError)

      expect(new_locale).to eq(:it)
      expect(subject.locale).to eq(:en)
    end
  end
end
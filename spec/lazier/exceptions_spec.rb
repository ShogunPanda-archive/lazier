#
# This file is part of the lazier gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Lazier::Exceptions::TranslationExceptionHandler do
  describe "#call" do
    it "should correctly raise exception" do
      subject = Lazier::Exceptions::TranslationExceptionHandler.new
      expect { subject.call(::I18n::MissingTranslation.new(1, 2, {}), 1, 2, 3) }.to raise_error(::I18n::MissingTranslationData)
      expect { subject.call(RuntimeError.new, 1, 2, 3) }.to raise_error(RuntimeError)
    end
  end
end

describe Lazier::Exceptions::MissingTranslation do
  describe "#initialize" do
    it "should initialize a good exception" do
      subject = Lazier::Exceptions::MissingTranslation.new("LOCALE", "MESSAGE")
      expect(subject.message).to eq("Unable to load the translation \"MESSAGE\" for the locale \"LOCALE\".")
    end
  end
end
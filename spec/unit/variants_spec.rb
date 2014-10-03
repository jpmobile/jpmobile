# -*- coding: utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))
require 'mail'
require 'jpmobile/mail'

describe Jpmobile::Mobile::AbstractMobile do
  subject{ Jpmobile::Mobile::AbstractMobile.new(nil, nil) }

  describe '#variants' do
    describe '#variants' do
      subject { super().variants }
      it { is_expected.to be === ['mobile'] }
    end
  end

  describe '#mail_variants' do
    describe '#mail_variants' do
      subject { super().mail_variants }
      it { is_expected.to eq([]) }
    end
  end
end

describe Jpmobile::Mobile::Docomo do
  subject{ Jpmobile::Mobile::Docomo.new(nil, nil) }

  describe '#variants' do
    describe '#variants' do
      subject { super().variants }
      it { is_expected.to eq(['mobile_docomo', 'mobile']) }
    end
  end

  describe '#mail_variants' do
    it 'have same value as #variants' do
      subject.mail_variants == subject.variants
    end
  end
end

describe Jpmobile::Mobile::Au do
  subject{ Jpmobile::Mobile::Au.new(nil, nil) }

  describe '#variants' do
    describe '#variants' do
      subject { super().variants }
      it { is_expected.to eq(['mobile_au', 'mobile']) }
    end
  end

  describe '#mail_variants' do
    it 'have same value as #variants' do
      subject.mail_variants == subject.variants
    end
  end
end

describe Jpmobile::Mobile::Softbank do
  subject{ Jpmobile::Mobile::Softbank.new(nil, nil) }

  describe '#variants' do
    describe '#variants' do
      subject { super().variants }
      it { is_expected.to eq(['mobile_softbank', 'mobile']) }
    end
  end

  describe '#mail_variants' do
    it 'have same value as #variants' do
      subject.mail_variants == subject.variants
    end
  end
end

describe Jpmobile::Mobile::Android do
  subject{ Jpmobile::Mobile::Android.new(nil, nil) }

  describe '#variants' do
    describe '#variants' do
      subject { super().variants }
      it { is_expected.to eq(['smart_phone_android', 'smart_phone']) }
    end
  end

  describe '#mail_variants' do
    it 'have same value as #variants' do
      subject.mail_variants == subject.variants
    end
  end
end

describe Jpmobile::Mobile::AndroidTablet do
  subject{ Jpmobile::Mobile::AndroidTablet.new(nil, nil) }

  describe '#variants' do
    describe '#variants' do
      subject { super().variants }
      it { is_expected.to eq(['tablet_android_tablet', 'tablet', 'smart_phone']) }
    end
  end

  describe '#mail_variants' do
    it 'have same value as #variants' do
      subject.mail_variants == subject.variants
    end
  end
end

describe Jpmobile::Mobile::Iphone do
  subject{ Jpmobile::Mobile::Iphone.new(nil, nil) }

  describe '#variants' do
    describe '#variants' do
      subject { super().variants }
      it { is_expected.to eq(['smart_phone_iphone', 'smart_phone']) }
    end
  end

  describe '#mail_variants' do
    it 'have same value as #variants' do
      subject.mail_variants == subject.variants
    end
  end
end

describe Jpmobile::Mobile::Ipad do
  subject{ Jpmobile::Mobile::Ipad.new(nil, nil) }

  describe '#variants' do
    describe '#variants' do
      subject { super().variants }
      it { is_expected.to eq(['tablet_ipad', 'tablet', 'smart_phone']) }
    end
  end

  describe '#mail_variants' do
    it 'have same value as #variants' do
      subject.mail_variants == subject.variants
    end
  end
end

describe Jpmobile::Mobile::WindowsPhone do
  subject{ Jpmobile::Mobile::WindowsPhone.new(nil, nil) }

  describe '#variants' do
    describe '#variants' do
      subject { super().variants }
      it { is_expected.to eq(['smart_phone_windows_phone', 'smart_phone']) }
    end
  end

  describe '#mail_variants' do
    it 'have same value as #variants' do
      subject.mail_variants == subject.variants
    end
  end
end

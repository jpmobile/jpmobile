require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

describe Jpmobile::Mobile::AbstractMobile do
  subject { Jpmobile::Mobile::AbstractMobile.new(nil, nil) }

  describe '#variants' do
    describe '#variants' do
      subject { super().variants }
      it { is_expected.to eq(['mobile']) }
    end
  end
end

describe Jpmobile::Mobile::Android do
  subject { Jpmobile::Mobile::Android.new(nil, nil) }

  describe '#variants' do
    describe '#variants' do
      subject { super().variants }
      it { is_expected.to eq(%w[smart_phone_android smart_phone]) }
    end
  end
end

describe Jpmobile::Mobile::AndroidTablet do
  subject { Jpmobile::Mobile::AndroidTablet.new(nil, nil) }

  describe '#variants' do
    describe '#variants' do
      subject { super().variants }
      it { is_expected.to eq(%w[tablet_android_tablet tablet smart_phone]) }
    end
  end
end

describe Jpmobile::Mobile::Iphone do
  subject { Jpmobile::Mobile::Iphone.new(nil, nil) }

  describe '#variants' do
    describe '#variants' do
      subject { super().variants }
      it { is_expected.to eq(%w[smart_phone_iphone smart_phone]) }
    end
  end
end

describe Jpmobile::Mobile::Ipad do
  subject { Jpmobile::Mobile::Ipad.new(nil, nil) }

  describe '#variants' do
    describe '#variants' do
      subject { super().variants }
      it { is_expected.to eq(%w[tablet_ipad tablet smart_phone]) }
    end
  end
end

describe Jpmobile::Mobile::WindowsPhone do
  subject { Jpmobile::Mobile::WindowsPhone.new(nil, nil) }

  describe '#variants' do
    describe '#variants' do
      subject { super().variants }
      it { is_expected.to eq(%w[smart_phone_windows_phone smart_phone]) }
    end
  end
end

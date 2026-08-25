require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

{
  Jpmobile::Mobile::AbstractMobile => ['mobile'],
  Jpmobile::Mobile::Android => %w[smart_phone_android smart_phone],
  Jpmobile::Mobile::AndroidTablet => %w[tablet_android_tablet tablet smart_phone],
  Jpmobile::Mobile::Iphone => %w[smart_phone_iphone smart_phone],
  Jpmobile::Mobile::Ipad => %w[tablet_ipad tablet smart_phone],
  Jpmobile::Mobile::WindowsPhone => %w[smart_phone_windows_phone smart_phone],
}.each do |mobile_class, variants|
  describe mobile_class do
    subject { mobile_class.new(nil, nil).variants }

    it { is_expected.to eq(variants) }
  end
end

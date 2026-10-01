require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

describe Jpmobile do
  around do |example|
    original_carriers = Jpmobile::Mobile.carriers

    example.run
  ensure
    Jpmobile::Mobile.carriers = original_carriers
  end

  it 'carriers の変更時に all_variants のキャッシュを無効化すること' do
    Jpmobile::Mobile.carriers = ['Android']
    expect(Jpmobile::Mobile.all_variants).to include('smart_phone_android')

    Jpmobile::Mobile.carriers = ['Iphone']

    expect(Jpmobile::Mobile.all_variants).to include('smart_phone_iphone')
    expect(Jpmobile::Mobile.all_variants).not_to include('smart_phone_android')
  end
end

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

  it 'lib が load path にない場合は追加すること' do
    lib_dir = File.expand_path('../../lib', __dir__)
    original_load_path = $LOAD_PATH.dup
    original_default_carriers = Jpmobile::Mobile::DEFAULT_CARRIERS
    $LOAD_PATH.reject! {|path| File.expand_path(path) == lib_dir }
    Jpmobile::Mobile.send(:remove_const, :DEFAULT_CARRIERS)

    # jpmobile.rb を再 load するため、トップレベルに一度きりの副作用を足すとここで二重に実行される。
    load File.join(lib_dir, 'jpmobile.rb')

    expect($LOAD_PATH).to include(lib_dir)
  ensure
    $LOAD_PATH.replace(original_load_path)
    Jpmobile::Mobile.send(:remove_const, :DEFAULT_CARRIERS) if Jpmobile::Mobile.const_defined?(:DEFAULT_CARRIERS, false)
    Jpmobile::Mobile.const_set(:DEFAULT_CARRIERS, original_default_carriers)
  end
end

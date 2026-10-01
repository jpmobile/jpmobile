require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

describe 'Jpmobile::Mobile' do
  {
    'Iphone' => 'iphone',
    'Android' => 'android',
    'WindowsPhone' => 'windowsphone',
    'BlackBerry' => 'blackberry',
    'Ipad' => 'ipad',
    'AndroidTablet' => 'androidtablet',
  }.each do |carrier, predicate|
    it "#{carrier}##{predicate}? should return true" do
      expect(Jpmobile::Mobile.const_get(carrier).new({}, {}).public_send(:"#{predicate}?")).to be(true)
    end
  end
end

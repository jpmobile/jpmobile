require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

describe 'Jpmobile::Mobile' do
  [
    [%w[Iphone iphone], true],
    [%w[Iphone android], false],
    [%w[Iphone ipad], false],

    [%w[Android android], true],
    [%w[Android iphone], false],

    [%w[Ipad ipad], true],
    [%w[Ipad iphone], false],

    [%w[AndroidTablet androidtablet], true],
    [%w[AndroidTablet android], false],

    [%w[WindowsPhone windowsphone], true],
    [%w[WindowsPhone blackberry], false],

    [%w[BlackBerry blackberry], true],
    [%w[BlackBerry windowsphone], false],
  ].each do |carrier, expected|
    it "#{carrier.first}##{carrier.last}? should be return #{expected}" do
      expect(Jpmobile::Mobile.const_get(carrier.first).new({}, {}).__send__(:"#{carrier.last}?")).to eq(expected)
    end
  end
end

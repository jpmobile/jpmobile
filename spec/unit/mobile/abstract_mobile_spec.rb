require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe Jpmobile::Mobile::AbstractMobile do
  def build(request = nil)
    described_class.new({}, request)
  end

  describe '#mail_variants' do
    it '2回目以降は memoize した同一オブジェクトを返すこと' do
      mobile = build
      first = mobile.mail_variants
      expect(mobile.mail_variants).to equal(first)
    end
  end

  describe '#content_transfer_encoding' do
    it 'text/plain で 7bit ならその値を返すこと' do
      headers = { 'Content-Type' => 'text/plain', 'Content-Transfer-Encoding' => '7bit' }
      expect(build.content_transfer_encoding(headers)).to eq('7bit')
    end

    it 'text/html かつ decorated なら quoted-printable を返すこと' do
      mobile = build
      mobile.decorated = true
      expect(mobile.content_transfer_encoding('Content-Type' => 'text/html')).to eq('quoted-printable')
    end

    it 'text/html かつ非 decorated で 7bit ならその値を返すこと' do
      mobile = build
      mobile.decorated = false
      headers = { 'Content-Type' => 'text/html', 'Content-Transfer-Encoding' => '7bit' }
      expect(mobile.content_transfer_encoding(headers)).to eq('7bit')
    end
  end

  describe '#utf8_to_mail_encode' do
    it 'mail_charset が ISO-2022-JP/Shift_JIS 以外ならそのまま返すこと' do
      mobile = build
      allow(mobile).to receive(:mail_charset).and_return('UTF-8')
      expect(mobile.utf8_to_mail_encode('テスト')).to eq('テスト')
    end
  end

  describe '.valid_ip?' do
    it 'IP 帯域定義が無いキャリアでは false を返すこと' do
      expect(described_class.valid_ip?('1.2.3.4')).to be_falsey
    end
  end

  describe '#params' do
    it 'request が parameters を持つ場合は parameters を参照すること' do
      mobile = build(double('request', parameters: { 'a' => '1' }))
      expect(mobile.send(:params)).to eq('a' => '1')
    end
  end
end

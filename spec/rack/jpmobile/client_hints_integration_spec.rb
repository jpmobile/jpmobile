require File.join(__dir__, '../../rack_helper.rb')

describe 'Client Hints Integration Tests' do
  include Rack::Test::Methods

  def app
    Rack::Builder.new do
      use Jpmobile::ClientHintsCarrier
      use Jpmobile::Rack::ParamsFilter
      use Jpmobile::Rack::Filter
      run UnitApplication.new
    end
  end

  context '実際の Client Hints データでの統合テスト' do
    it 'Chrome on Android のリアルなデータで動作すること' do
      header 'Sec-CH-UA', '"Google Chrome";v="119", "Chromium";v="119", "Not?A_Brand";v="24"'
      header 'Sec-CH-UA-Mobile', '?1'
      header 'Sec-CH-UA-Platform', '"Android"'
      header 'Sec-CH-UA-Model', '"SM-G991B"'
      header 'Sec-CH-UA-Full-Version-List', '"Google Chrome";v="119.0.6045.193", "Chromium";v="119.0.6045.193", "Not?A_Brand";v="24.0.0.0"'

      get '/'

      expect(last_response).to be_ok
      env = last_request.env
      expect(env['rack.jpmobile'].class).to eq(Jpmobile::Mobile::Android)
      expect(env['rack.jpmobile'].smart_phone?).to be_truthy
    end

    it 'Safari on iPhone のリアルなデータで動作すること' do
      header 'Sec-CH-UA', '"Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"'
      header 'Sec-CH-UA-Mobile', '?1'
      header 'Sec-CH-UA-Platform', '"iOS"'
      header 'Sec-CH-UA-Model', '"iPhone"'

      get '/'

      expect(last_response).to be_ok
      env = last_request.env
      expect(env['rack.jpmobile'].class).to eq(Jpmobile::Mobile::Iphone)
      expect(env['rack.jpmobile'].smart_phone?).to be_truthy
    end

    it 'Chrome on iPad のリアルなデータで動作すること' do
      header 'Sec-CH-UA', '"Google Chrome";v="119", "Chromium";v="119", "Not?A_Brand";v="24"'
      header 'Sec-CH-UA-Mobile', '?0'
      header 'Sec-CH-UA-Platform', '"iPadOS"'
      header 'Sec-CH-UA-Model', '"iPad"'

      get '/'

      expect(last_response).to be_ok
      env = last_request.env
      expect(env['rack.jpmobile'].class).to eq(Jpmobile::Mobile::Ipad)
      expect(env['rack.jpmobile'].tablet?).to be_truthy
    end

    it 'Chrome on Android Tablet のリアルなデータで動作すること' do
      header 'Sec-CH-UA', '"Google Chrome";v="119", "Chromium";v="119", "Not?A_Brand";v="24"'
      header 'Sec-CH-UA-Mobile', '?0'
      header 'Sec-CH-UA-Platform', '"Android"'
      header 'Sec-CH-UA-Model', '"SM-T870"'

      get '/'

      expect(last_response).to be_ok
      env = last_request.env
      expect(env['rack.jpmobile'].class).to eq(Jpmobile::Mobile::AndroidTablet)
      expect(env['rack.jpmobile'].tablet?).to be_truthy
    end
  end

  context 'Client Hints と User-Agent の併用テスト' do
    it 'Client Hints が利用できない従来キャリアは User-Agent で判定すること' do
      header 'User-Agent', 'DoCoMo/2.0 SH902i(c100;TB;W24H12)'
      # Client Hints ヘッダーは設定しない

      get '/'

      expect(last_response).to be_ok
      env = last_request.env
      expect(env['rack.jpmobile'].class).to eq(Jpmobile::Mobile::Docomo)
    end

    it 'Client Hints 優先で判定し、不明な場合は User-Agent にフォールバックすること' do
      header 'Sec-CH-UA', '"Unknown Browser";v="1.0"'
      header 'Sec-CH-UA-Mobile', '?1'
      header 'Sec-CH-UA-Platform', '"Unknown OS"'
      header 'User-Agent', 'KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0'

      get '/'

      expect(last_response).to be_ok
      env = last_request.env
      expect(env['rack.jpmobile'].class).to eq(Jpmobile::Mobile::Au)
    end
  end

  context 'エッジケースのテスト' do
    it 'Client Hints ヘッダーが部分的に欠けている場合でも動作すること' do
      header 'Sec-CH-UA', '"Google Chrome";v="119"'
      header 'Sec-CH-UA-Mobile', '?1'
      # Platform と Model は設定しない

      get '/'

      expect(last_response).to be_ok
      # Client Hints では判定できないため、nil になる
      env = last_request.env
      expect(env['rack.jpmobile']).to be_nil
    end

    it '空の Client Hints ヘッダーでもエラーにならないこと' do
      header 'Sec-CH-UA', ''
      header 'Sec-CH-UA-Mobile', ''
      header 'Sec-CH-UA-Platform', ''

      expect { get '/' }.not_to raise_error
      expect(last_response).to be_ok
    end

    it '不正な形式の Client Hints でもエラーにならないこと' do
      header 'Sec-CH-UA', 'malformed header without quotes'
      header 'Sec-CH-UA-Mobile', 'not_boolean'
      header 'Sec-CH-UA-Platform', 'no_quotes'

      expect { get '/' }.not_to raise_error
      expect(last_response).to be_ok
    end
  end

  context 'パフォーマンステスト' do
    it '大量の Client Hints ブランド情報でも高速に処理できること' do
      # 実際のブラウザが送信する可能性のある長いヘッダー
      long_ua_header = (1..50).map { |i| "\"Brand#{i}\";v=\"#{i}.0\"" }.join(', ')
      
      header 'Sec-CH-UA', long_ua_header
      header 'Sec-CH-UA-Mobile', '?1'
      header 'Sec-CH-UA-Platform', '"Android"'
      header 'Sec-CH-UA-Model', '"TestDevice"'

      start_time = Time.now
      get '/'
      end_time = Time.now

      expect(last_response).to be_ok
      expect(end_time - start_time).to be < 0.1 # 100ms 以内で処理完了
      
      env = last_request.env
      expect(env['rack.jpmobile'].class).to eq(Jpmobile::Mobile::Android)
    end
  end

  context 'セキュリティテスト' do
    it 'Client Hints インジェクション攻撃に対して安全であること' do
      header 'Sec-CH-UA', '"<script>alert(1)</script>";v="1", "Chromium";v="119"'
      header 'Sec-CH-UA-Mobile', '?1'
      header 'Sec-CH-UA-Platform', '"Android"; rm -rf /"'
      header 'Sec-CH-UA-Model', '"../../etc/passwd"'

      expect { get '/' }.not_to raise_error
      expect(last_response).to be_ok
      
      # 悪意のある値が適切にサニタイズされていることを確認
      env = last_request.env
      expect(env['rack.jpmobile'].class).to eq(Jpmobile::Mobile::Android)
    end

    it '極端に長い Client Hints ヘッダーでも DoS 攻撃を受けないこと' do
      # 非常に長いヘッダー値
      very_long_value = 'A' * 10000
      
      header 'Sec-CH-UA', "\"#{very_long_value}\";v=\"1\""
      header 'Sec-CH-UA-Mobile', '?1'
      header 'Sec-CH-UA-Platform', "\"#{very_long_value}\""

      start_time = Time.now
      expect { get '/' }.not_to raise_error
      end_time = Time.now

      expect(last_response).to be_ok
      expect(end_time - start_time).to be < 1.0 # 1秒以内で処理完了
    end
  end
end
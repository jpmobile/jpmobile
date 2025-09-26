# User-Agent Client Hints から生成すべき class 名を判定する
module Jpmobile
  module ClientHintsParser
    def parse_client_hints(sec_ch_ua, sec_ch_ua_mobile, sec_ch_ua_platform, sec_ch_ua_model, sec_ch_ua_full_version_list)
      {
        brands: parse_sec_ch_ua(sec_ch_ua),
        mobile: parse_boolean_hint(sec_ch_ua_mobile),
        platform: parse_string_hint(sec_ch_ua_platform),
        model: parse_string_hint(sec_ch_ua_model),
        full_version_list: parse_sec_ch_ua(sec_ch_ua_full_version_list),
      }
    end

    def parse_sec_ch_ua(header_value)
      return [] unless header_value

      # Sec-CH-UA format: "Google Chrome";v="91", "Chromium";v="91", " Not;A Brand";v="99"
      brands = []
      header_value.scan(/"([^"]+)";v="([^"]+)"/) do |brand, version|
        brands << { brand: brand, version: version.strip }
      end
      brands
    end

    def parse_boolean_hint(header_value)
      return nil unless header_value

      header_value.strip == '?1'
    end

    def parse_string_hint(header_value)
      return nil unless header_value

      # Remove quotes if present
      header_value.gsub(/^"|"$/, '').strip
    end
  end

  class ClientHintsCarrier
    include ClientHintsParser
    def initialize(app)
      @app = app
    end

    def call(env)
      # Client Hints から mobile carrier を判定
      mobile_carrier = detect_carrier_from_client_hints(env)

      # Client Hints で判定できない場合は従来のUser-Agentベースの判定にフォールバック
      mobile_carrier ||= Jpmobile::Mobile::AbstractMobile.carrier(env)

      env['rack.jpmobile'] = mobile_carrier

      @app.call(env)
    end

    private

    def detect_carrier_from_client_hints(env)
      # Client Hints headers を取得
      sec_ch_ua = env['HTTP_SEC_CH_UA']
      sec_ch_ua_mobile = env['HTTP_SEC_CH_UA_MOBILE']
      sec_ch_ua_platform = env['HTTP_SEC_CH_UA_PLATFORM']
      sec_ch_ua_model = env['HTTP_SEC_CH_UA_MODEL']
      sec_ch_ua_full_version_list = env['HTTP_SEC_CH_UA_FULL_VERSION_LIST']

      return nil unless sec_ch_ua

      # Client Hints parser を使用してデバイス情報を解析
      client_hints_info = parse_client_hints(
        sec_ch_ua,
        sec_ch_ua_mobile,
        sec_ch_ua_platform,
        sec_ch_ua_model,
        sec_ch_ua_full_version_list,
      )

      # Client Hints 情報から適切なキャリアクラスを判定
      determine_carrier_from_hints(env, client_hints_info)
    end

    def determine_carrier_from_hints(env, hints)
      request = ::Rack::Request.new(env)

      if hints[:mobile]
        determine_mobile_carrier(env, request, hints)
      else
        determine_desktop_carrier(env, request, hints)
      end
    end

    def determine_mobile_carrier(env, request, hints)
      return determine_android_mobile_carrier(env, request, hints) if android_platform?(hints)
      return determine_ios_mobile_carrier(env, request, hints) if ios_platform?(hints)

      determine_other_mobile_carrier(env, request, hints)
    end

    def determine_desktop_carrier(env, request, hints)
      return Jpmobile::Mobile::Ipad.new(env, request) if ipad_device?(hints)
      return Jpmobile::Mobile::Ipad.new(env, request) if ipados_platform?(hints)
      return Jpmobile::Mobile::AndroidTablet.new(env, request) if android_platform?(hints)

      nil
    end

    def determine_android_mobile_carrier(env, request, hints)
      return Jpmobile::Mobile::AndroidTablet.new(env, request) if android_tablet?(hints)

      Jpmobile::Mobile::Android.new(env, request)
    end

    def determine_ios_mobile_carrier(env, request, hints)
      return Jpmobile::Mobile::Ipad.new(env, request) if ipad_device?(hints) || ipados_platform?(hints)

      Jpmobile::Mobile::Iphone.new(env, request)
    end

    def determine_other_mobile_carrier(env, request, hints)
      case hints[:platform]&.downcase
      when /windows/
        Jpmobile::Mobile::WindowsPhone.new(env, request)
      when /blackberry/
        Jpmobile::Mobile::BlackBerry.new(env, request)
      end
    end

    def android_platform?(hints)
      hints[:platform]&.match(/android/i)
    end

    def ios_platform?(hints)
      hints[:platform]&.match(/ios/i)
    end

    def ipados_platform?(hints)
      hints[:platform]&.match(/ipados/i)
    end

    def ipad_device?(hints)
      hints[:model]&.match(/ipad/i)
    end

    def android_tablet?(hints)
      # Android でモバイル=trueでもタブレットの可能性がある
      # モデル名やその他の情報から判定
      model = hints[:model]&.downcase
      return false unless model

      # 一般的なタブレットのモデル名パターン
      tablet_patterns = [
        /tab/, /pad/, /slate/, /nexus\s*[79]/, /nexus\s*10/,
        /galaxy\s*tab/, /xoom/, /transformer/, /kindle/
      ]

      tablet_patterns.any? {|pattern| model.match?(pattern) }
    end
  end
end

class Rack::Request
  include ::Jpmobile::RequestWithMobile
end

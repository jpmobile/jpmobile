module Jpmobile::Mobile
  # 携帯電話の抽象クラス。
  class AbstractMobile
    # 対応するuser-agentの正規表現
    USER_AGENT_REGEXP = nil

    def initialize(env, request)
      @env            = env
      @request        = request
      @_variants      = nil
    end

    # クッキーをサポートしているか。
    def supports_cookie?
      false
    end

    # smartphone かどうか
    def smart_phone?
      false
    end

    # tablet かどうか
    def tablet?
      false
    end

    def default_charset
      'UTF-8'
    end

    # for view selector
    def variants
      return @_variants if @_variants

      @_variants = self.class.ancestors.select {|c| c.to_s =~ /^Jpmobile/ }.map! do |klass|
        klass = klass.to_s.
                  gsub('Jpmobile::', '').
                  gsub('AbstractMobile::', '').
                  gsub('Mobile::SmartPhone', 'smart_phone').
                  gsub('Mobile::Tablet', 'tablet').
                  gsub('::', '_').
                  gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
                  gsub(/([a-z\d])([A-Z])/, '\1_\2').
                  downcase
        (klass =~ /abstract/) ? 'mobile' : klass
      end

      if @_variants.include?('tablet')
        @_variants = @_variants.reject {|v| v == 'mobile' }.map! {|v| v.gsub('mobile_', 'tablet_') }
      elsif @_variants.include?('smart_phone')
        @_variants = @_variants.reject {|v| v == 'mobile' }.map! {|v| v.gsub('mobile_', 'smart_phone_') }
      end

      @_variants || []
    end

    class << self
      # リクエストがこのクラスに属するか調べる
      # メソッド名に関して非常に不安
      def check_carrier(env)
        user_agent_regexp && user_agent_regexp.match(env['HTTP_USER_AGENT'])
      end

      def user_agent_regexp
        @_user_agent_regexp ||= self::USER_AGENT_REGEXP
      end

      def add_user_agent_regexp(regexp)
        @_user_agent_regexp = Regexp.union(user_agent_regexp, regexp)
      end

      # Client Hints でリクエストがこのクラスに属するか調べる
      def check_client_hints(env)
        nil
      end

      def carrier(env)
        # Client Hints が送信されている場合は優先して判定する
        if env['HTTP_SEC_CH_UA_MOBILE'] || env['HTTP_SEC_CH_UA_PLATFORM']
          ::Jpmobile::Mobile.carriers.each do |const|
            c = ::Jpmobile::Mobile.const_get(const)
            if c.check_client_hints(env)
              res = ::Rack::Request.new(env)
              return c.new(env, res)
            end
          end
        end

        ::Jpmobile::Mobile.carriers.each do |const|
          c = ::Jpmobile::Mobile.const_get(const)
          if c.check_carrier(env)
            res = ::Rack::Request.new(env)
            return c.new(env, res)
          end
        end

        nil
      end
    end

    # XXX: lib/jpmobile.rbのautoloadで先に各キャリアの定数を定義しているから動くのです
    Jpmobile::Mobile.carriers.each do |carrier|
      carrier_class = Jpmobile::Mobile.const_get(carrier)
      next if carrier_class == self

      define_method :"#{carrier.downcase}?" do
        self.is_a?(carrier_class)
      end
    end

    private

    # リクエストのパラメータ。
    def params
      if @request.respond_to? :parameters
        @request.parameters
      else
        @request.params
      end
    end
  end
end

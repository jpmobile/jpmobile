# = セッションIDの付与
require 'active_support/version'

module Jpmobile
  module SessionID
    require 'action_dispatch/middleware/session/abstract_store'

    extend ActionDispatch::Session::Compatibility
  end

  module ParamsOverCookie
    def extract_session_id(req)
      if req.params[@key] && !@cookie_only
        sid = req.params[@key]
      end
      sid ||= req.cookies[@key]
      sid
    end
  end

  module TransSid
    def self.included(controller)
      controller.after_action(:append_session_id_parameter)
    end

    protected

    # URLにsession_idを追加する。
    def default_url_options
      result = super || {}.with_indifferent_access
      return result unless request # for test process
      return result unless apply_trans_sid?

      result.merge({ session_key.to_sym => jpmobile_session_id })
    end

    private

    # session_keyを返す。
    def session_key
      Rails.application.config.session_options.merge(request.session_options || {})[:key] ||
        ActionDispatch::Session::AbstractStore::DEFAULT_OPTIONS[:key]
    end

    # session_idを返す
    # rack 1.4 (rails3) request.session_options[:id]
    # rack 1.5 (rails4) request.session.id
    def jpmobile_session_id
      request.session_options[:id] || request.session.id
    end

    # session_idを埋め込むためのhidden fieldを出力する。
    def sid_hidden_field_tag
      "<input type=\"hidden\" name=\"#{CGI.escapeHTML session_key}\" value=\"#{CGI.escapeHTML jpmobile_session_id}\" />"
    end

    # formにsession_idを追加する。
    def append_session_id_parameter
      return unless request # for test process
      return unless apply_trans_sid?
      return unless jpmobile_session_id

      response.body = response.body.gsub(%r{(</form>)}i, sid_hidden_field_tag + '\1')
    end
  end

  module TransSidRedirecting
    def redirect_to(options = {}, response_status = {})
      if apply_trans_sid? && jpmobile_session_id && options != :back && options !~ /^\w[\w+.-]*:.*/
        case options
        when String
          unless options.match?(/#{session_key}/)
            url = URI.parse(options)
            if url.query
              url.query += "&#{session_key}=#{jpmobile_session_id}"
            else
              url.query = "#{session_key}=#{jpmobile_session_id}"
            end
            options = url.to_s
          end
        when Hash
          unless options[session_key.to_sym]
            options[session_key.to_sym] = jpmobile_session_id
          end
        end
      end

      super(options, response_status)
    end
  end
end

module ActionController
  class Metal #:nodoc:
    class_attribute :trans_sid_mode

    class << self
      def trans_sid(mode = :mobile)
        include Jpmobile::TransSid

        self.trans_sid_mode = mode
      end
    end

    private

    # trans_sidを適用すべきかを返す。
    def apply_trans_sid?
      # session_id が blank の場合は適用しない
      return false if trans_sid_mode && jpmobile_session_id.blank?

      case trans_sid_mode
      when :always
        return true
      when :mobile
        if request.mobile? && !request.mobile.supports_cookie?
          return true
        end
      end

      false
    end
  end
end

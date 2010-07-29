# -*- coding: utf-8 -*-
# = セッションIDの付与
require 'active_support/version'

module ParamsOverCookie
  def self.included(base)
    base.class_eval do
      # cookie よりも params を先に見るパッチ
      def extract_session_id_with_jpmobile(env)
        request = Rack::Request.new(env)
        if request.params[@key] and !@cookie_only
          sid = request.params[@key] unless @cookie_only
        end
        sid ||= request.cookies[@key]
        sid
      end
      alias_method_chain :extract_session_id, :jpmobile
    end
  end
end

module ActionDispatch
  module Session
    class AbstractStore
      include ParamsOverCookie
    end
  end
end

module ActionController
  module Redirecting
    def redirect_to_with_jpmobile(options = {}, response_status = {})
      if apply_trans_sid? and jpmobile_session_id
        case options
        when String
          unless options.match(/#{session_key}/)
            url = URI.parse(options)
            if url.query
              url.query += "&#{session_key}=#{jpmobile_session_id}"
            else
              url.query = "#{session_key}=#{jpmobile_session_id}"
            end
            options = url.to_s
          end
        when %r{^\w[\w+.-]*:.*}
        when :back
        else
          unless options[session_key.to_sym]
            options[session_key.to_sym] = jpmobile_session_id
          end
        end
      end

      redirect_to_without_jpmobile(options, response_status)
    end

    alias_method_chain :redirect_to, :jpmobile
  end

  class Base #:nodoc:
    class_inheritable_accessor :trans_sid_mode

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
      return false if trans_sid_mode and jpmobile_session_id.blank?

      case trans_sid_mode
      when :always
        session.inspect
        return true
      when :mobile
        if request.mobile? and !request.mobile.supports_cookie?
          session.inspect
          return true
        end
      end

      return false
    end
  end
end

module Jpmobile::TransSid #:nodoc:
  def self.included(controller)
    controller.after_filter(:append_session_id_parameter)
  end

  protected
  # URLにsession_idを追加する。
  def default_url_options
    result = super || {}
    return result unless request # for test process
    return result unless apply_trans_sid?
    return result.merge({session_key => jpmobile_session_id})
  end

  private
  # session_keyを返す。
  def session_key
    unless key = Rails.application.config.session_options.merge(request.session_options || {})[:key]
      key = ActionDispatch::Session::AbstractStore::DEFAULT_OPTIONS[:key]
    end
    key
  end
  # session_idを返す
  def jpmobile_session_id
    request.session_options[:id] rescue session.session_id
  end
  # session_idを埋め込むためのhidden fieldを出力する。
  def sid_hidden_field_tag
    "<input type=\"hidden\" name=\"#{CGI::escapeHTML session_key}\" value=\"#{CGI::escapeHTML jpmobile_session_id}\" />"
  end
  # formにsession_idを追加する。
  def append_session_id_parameter
    return unless request # for test process
    return unless apply_trans_sid?
    return unless jpmobile_session_id
    response.body.gsub!(%r{(</form>)}i, sid_hidden_field_tag+'\1')
  end
end

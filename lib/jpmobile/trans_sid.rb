# -*- coding: utf-8 -*-
# = セッションIDの付与
require 'active_support/version'

module ParamsOverCookie
  def self.included(base)
    base.class_eval do
      # cookie よりも params を先に見るパッチ
      def load_session_with_jpmobile(env)
        request = Rack::Request.new(env)
        unless @cookie_only
          sid = request.params[@key]
        end
        sid ||= request.cookies[@key]

        sid, session = get_session(env, sid)
        [sid, session]
      end
      alias_method_chain :load_session, :jpmobile
    end
  end
end

module ActionController
  # cookie よりも params を先に見るパッチ
  Session::AbstractStore.send :include, ParamsOverCookie

  class Base #:nodoc:
    class_inheritable_accessor :trans_sid_mode
    alias :redirect_to_full_url_without_jpmobile :redirect_to_full_url

    def transit_sid_mode(*args)
      STDERR.puts "Method transit_sid is now deprecated. Use trans_sid instead."
      trans_sid_mode(*args)
    end

    def redirect_to_full_url(url, status)
      if apply_trans_sid? and !url.match(/#{session_key}/) and jpmobile_session_id
        uri = URI.parse(url)
        if uri.query
          uri.query += "&#{session_key}=#{jpmobile_session_id}"
        else
          uri.query = "#{session_key}=#{jpmobile_session_id}"
        end
        url = uri.to_s
      end

      redirect_to_full_url_without_jpmobile(url, status)
    end

    class << self
      # 2.3.x or higher
      def trans_sid(mode = :mobile)
        include Jpmobile::TransSid
        self.trans_sid_mode = mode
      end

      def transit_sid(*args)
        STDERR.puts "Method transit_sid is now deprecated. Use trans_sid instead."
        trans_sid(*args)
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
  def default_url_options(options=nil)
    result = super || {}
    return result unless request # for test process
    return result unless apply_trans_sid?
    return result.merge({ session_key => jpmobile_session_id })
  end

  private
  # session_keyを返す。
  def session_key
    ActionController::Base.session_options.merge(request.session_options || {})[:key]
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

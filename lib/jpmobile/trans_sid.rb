# = セッションIDの付与
#
# based on http://moriq.tdiary.net/20070209.html#p01
# by moriq <moriq@moriq.com>
#
# cookie support detection inspired by takai http://recompile.net/
#
# Rails 2.0.2 support is based on the code contributed
# by masuidrive <masuidrive (at) masuidrive.jp>

# FastCGI環境では(どういうわけか) cgi.query_string でクエリ文字列を取得できないので
# ENV['QUERY_STRING'] に代入しておく。
module ActionController
  class CgiRequest
    alias_method :initialize_without_ext, :initialize
    def initialize(cgi, options = {})
      initialize_without_ext(cgi, options)
      ENV['QUERY_STRING'] = query_string
    end
  end
end

class ActionController::Base #:nodoc:
  class_inheritable_accessor :trans_sid_mode
  alias :transit_sid_mode :trans_sid_mode
  class << self
    def trans_sid(mode=:mobile)
      include Jpmobile::TransSid
      self.trans_sid_mode = mode
      unless mode == :none
        # CSRF対策への対策
        session :cookie_only => false
        # url/postからsession_keyを取得できるようhookを追加する
        unless ::CGI::Session.private_method_defined?(:initialize_without_session_key_fixation)
          ::CGI::Session.class_eval do
            alias_method :initialize_without_session_key_fixation, :initialize
            def initialize(cgi, options = {})
              key = options['session_key']
              if cgi.cookies[key].empty?
                session_id = (CGI.parse(cgi.env_table['RAW_POST_DATA'])[key] rescue nil) ||
                  (CGI.parse(ENV['QUERY_STRING'] || cgi.query_string)[key] rescue nil)
                cgi.params[key] = session_id unless session_id.blank?
              end
              initialize_without_session_key_fixation(cgi, options)
            end
          end
        end
      end
    end
    alias :transit_sid :trans_sid
  end
end

module Jpmobile::TransSid #:nodoc:
  def self.included(controller)
    controller.after_filter(:append_session_id_parameter)
  end

  protected
  # URLにsession_idを追加する。
  def default_url_options(options=nil)
    return unless request # for test process
    return unless apply_trans_sid?
    { session_key => session.session_id }
  end

  private
  # session_keyを返す。
  def session_key
    if session_enabled?
      session_key = request.session_options[:session_key] || '_session_id'
    end
  end
  # session_idを埋め込むためのhidden fieldを出力する。
  def sid_hidden_field_tag
    "<input type=\"hidden\" name=\"#{CGI::escapeHTML session_key}\" value=\"#{CGI::escapeHTML session.session_id}\" />"
  end
  # formにsession_idを追加する。
  def append_session_id_parameter
    return unless request # for test process
    return unless apply_trans_sid?
    response.body.gsub!(%r{(</form>)}i, sid_hidden_field_tag+'\1')
  end
  # trans_sidを適用すべきかを返す。
  def apply_trans_sid?
    return false unless session_enabled?
    return false if trans_sid_mode == :none
    return true if trans_sid_mode == :always
    if trans_sid_mode == :mobile
      if request.mobile?
        return !request.mobile.supports_cookie?
      else
        return false
      end
    end
    return false
  end
end

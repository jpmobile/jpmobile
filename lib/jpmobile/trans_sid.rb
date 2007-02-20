# = セッションIDの付与
#
# based on http://moriq.tdiary.net/20070209.html#p01
# by moriq <moriq@moriq.com>

class ActionController::Base #:nodoc:
  cattr_accessor :transit_sid_mode
  def self.transit_sid(mode=:mobile)
    include Jpmobile::TransSid
    self.transit_sid_mode = mode
  end
end

module Jpmobile::TransSid #:nodoc:
  def self.included(controller)
    controller.after_filter(:append_session_id_parameter)
  end

  protected
  def default_url_options(options)
    return unless request # for test process 
    return if transit_sid_mode == :none || (transit_sid_mode == :mobile && !request.mobile?)
    session_key = request.session_options[:session_key] || '_session_id'
    { session_key => session.session_id }
  end
  
  private
  def append_session_id_parameter
    return unless request # for test process 
    return if transit_sid_mode == :none || (transit_sid_mode == :mobile && !request.mobile?)
    session_key = request.session_options[:session_key] || '_session_id'
    response.body.gsub!(%r{(</form>)}i, "<input type='hidden' name='#{CGI::escapeHTML session_key}' value='#{CGI::escapeHTML session.session_id}'>\\1")
  end
end

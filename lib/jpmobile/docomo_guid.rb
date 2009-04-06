#DoCoMoの時guid=onの付与
class ActionController::Base #:nodoc:
  class_inheritable_accessor :docomo_guid_mode

  class << self
    def docomo_guid(mode=:docomo)
      include Jpmobile::DocomoGuid
      self.docomo_guid_mode = mode
    end
  end
end


module Jpmobile::DocomoGuid #:nodoc:
  protected
  def default_url_options options=nil
    result = super || {}
    return result unless request # for test process
    return result unless apply_add_guid?
    return result.merge({:guid => "ON"})
  end

  #guid=ONを付与すべきか否かを返す
  def apply_add_guid?
    return true if docomo_guid_mode == :always
    return false if docomo_guid_mode == :none

    return false unless request.mobile?
    return false unless request.mobile.is_a?(Jpmobile::Mobile::Docomo)
    return false if not_apply_guid_user_agent?

    if docomo_guid_mode == :valid_ip
      return false unless request.mobile.valid_ip?
    end

    return true
  end

  def not_apply_guid_user_agent?
    request.user_agent.match(/(?:Googlebot|Y!J-SRD\/1\.0|Y!J-MBS\/1\.0)/)
  end
end

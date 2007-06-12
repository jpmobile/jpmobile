require File.dirname(__FILE__)+'/helper'

class TestBaseController < ActionController::Base
  session :session_key => '_session_id'
  def form
    render :inline=>%{<% form_tag do %>Hello<% end %>}
  end
  def link
    render :inline=>%{<%= link_to "linkto" %>}
  end
end

class DefaultController < TestBaseController;
end

class AlwaysController < TestBaseController
  transit_sid :always
end

class NoneController < TestBaseController
  transit_sid :none
end

class MobileController < TestBaseController
  transit_sid :mobile
end

class TransitSidTest < Test::Unit::TestCase
  def test_settings
    assert_equal nil, DefaultController.transit_sid_mode
    assert_equal :always, AlwaysController.transit_sid_mode
    assert_equal :none, NoneController.transit_sid_mode
    assert_equal :mobile, MobileController.transit_sid_mode
  end
  def test_transit_sid_default
    init DefaultController
    test_transit_sid_disabled
  end
  def test_transit_sid_none
    init NoneController
    test_transit_sid_disabled
  end
  def test_transit_sid_always
    init AlwaysController
    test_transit_sid_enabled
  end
  def test_transit_sid_always
    init MobileController
    # 普通のブラウザからは無効
    test_transit_sid_disabled
    # 携帯からの場合は有効
    user_agent "DoCoMo/2.0 SH902i(c100;TB;W24H12)"
    test_transit_sid_enabled
  end
  private
  def test_transit_sid_disabled
    get :form
    assert_response :success
    assert_match %r{<form action="/.+?/form" method="post">Hello</form>}, @response.body
    get :link
    assert_response :success
    assert_match %r{<a href="/.+?/link">linkto</a>}, @response.body
  end
  def test_transit_sid_enabled
    get :form
    assert_response :success
    assert_match %r{<form action="/.+?/form\?_session_id=mysessionid" method="post">Hello<input type='hidden' name='_session_id' value='mysessionid'></form>}, @response.body
    get :link
    assert_response :success
    assert_match %r{<a href="/.+?/link\?_session_id=mysessionid">linkto</a>}, @response.body
  end
end

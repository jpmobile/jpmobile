require File.dirname(__FILE__)+'/helper'

class PictogramTestController < ActionController::Base
  mobile_filter
  def docomo_cr
    render :text=>"&#xE63E;"
  end
  def docomo_utf8
    render :text=>"\xee\x98\xbe"
  end
  def au_cr
    render :text=>"&#xE488;"
  end
  def au_utf8
    render :text=>[0xe488].pack("U")
  end
  def query
    @q = params[:q]
    render :text=>@q
  end
end

class PictogramFunctionalTest < Test::Unit::TestCase
  def setup
    init PictogramTestController
  end
  def test_docomo
    # PCから
    get :docomo_cr
    assert_equal "&#xE63E;", @response.body
    get :docomo_utf8
    assert_equal "\xee\x98\xbe", @response.body
    
    # DoCoMo携帯から
    user_agent "DoCoMo/2.0 SH902i(c100;TB;W24H12)"
    get :docomo_cr
    assert_equal "\xf8\x9f", @response.body
    get :docomo_utf8
    assert_equal "\xf8\x9f", @response.body
    get :query, :q=>"\xf8\x9f"
    assert_equal "\xee\x98\xbe", assigns["q"]
    assert_equal "\xf8\x9f", @response.body

    # Au携帯電話から
    #user_agent "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0"
    #get :docomo_cr
    #assert_equal "\xf6\xf0", @response.body
    #get :docomo_utf8
    #assert_equal "\xf6\xf0", @response.body
  end
  def test_au
    # PCから
    get :au_cr
    assert_equal "&#xE488;", @response.body
    get :au_utf8
    assert_equal [0xe488].pack("U"), @response.body

    # Au携帯電話から
    user_agent "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0"
    get :au_cr
    assert_equal "\xf6\x60", @response.body
    get :au_utf8
    assert_equal "\xf6\x60", @response.body
    get :query, :q=>"\xf6\x60"
    assert_equal [0xe488].pack("U"), assigns["q"]
    assert_equal "\xf6\x60", @response.body
  end
end

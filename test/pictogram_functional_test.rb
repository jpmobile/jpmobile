require File.dirname(__FILE__)+'/helper'

class PictogramTestController < ActionController::Base
  mobile_filter
  def docomo_cr
    render :text=>"&#xE63E;"
  end
  def docomo_utf8
    render :text=>"\xee\x98\xbe"
  end
  def query
    @q = params[:q]
    render :text=>@q
  end
end

class PictogramFunctionalTest < Test::Unit::TestCase
  def test_docomo
    init PictogramTestController
    
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
  end
end

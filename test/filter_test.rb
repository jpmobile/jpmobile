require File.dirname(__FILE__)+'/helper'

class FilterTest < Test::Unit::TestCase
  def setup
    @controller = ActionController::Base.new
    @controller.response = ActionController::AbstractResponse.new

    @aiu_sjis = "\202\240\202\242\202\244" # あいう
    @aiu_utf8 = "\343\201\202\343\201\204\343\201\206" # あいう

    @aiu_zhz = "\343\201\202\357\275\262\343\202\246" # あイウ (イ半角), UTF-8
    @aiu_zzz = "\343\201\202\343\202\244\343\202\246" # あイウ, UTF-8
    @aiu_zhh = "\343\201\202\357\275\262\357\275\263" # あイウ (イウ半角), UTF-8

    @abracadabra_z_utf8 = "\343\202\242\343\203\226\343\203\251\343\202\253\343\203\200\343\203\226\343\203\251" # アブラカダブラ, UTF-8
    @abracadabra_h_utf8 = "\357\275\261\357\276\214\357\276\236\357\276\227\357\275\266\357\276\200\357\276\236\357\276\214\357\276\236\357\276\227" # アブラカダブラ(半角), UTF-8
    @abracadabra_z_sjis = "\203A\203u\203\211\203J\203_\203u\203\211" # アブラカダブラ, Shift_JIS
  end
  def test_filter_sjis
    filter = Jpmobile::Filter::Sjis.new
    assert_equal(@aiu_sjis, filter.to_external(@aiu_utf8, nil))
    assert_equal(@aiu_utf8, filter.to_internal(@aiu_sjis, nil))
  end
  def test_filter_hankaku
    filter = Jpmobile::Filter::HankakuKana.new

    assert_equal(@aiu_zzz, filter.to_internal(@aiu_zhz, nil))
    assert_equal(@aiu_zzz, filter.to_internal(@aiu_zzz, nil))
    assert_equal(@aiu_zhh, filter.to_external(@aiu_zhz, nil))
    assert_equal(@aiu_zhh, filter.to_external(@aiu_zzz, nil))

    assert_equal(@abracadabra_z_utf8, filter.to_internal(@abracadabra_h_utf8, nil))
    assert_equal(@abracadabra_h_utf8, filter.to_external(@abracadabra_z_utf8, nil))
  end
  def test_sjis_filter_for_docomo
    @controller.request = request_with_ua("DoCoMo/2.0 SH902i(c100;TB;W24H12)", "QUERY_STRING"=>"test=test&abra=%83A%83u%83%89%83J%83_%83u%83%89") # アブラカダブラ, Shift_JIS, urlencoded
    @controller.params = @controller.request.params

    # before filter のテスト(携帯電話からのパラメータがutf-8で格納されているか)
    filter = Jpmobile::Filter::Sjis.new
    filter.before(@controller)
    assert_equal(@abracadabra_z_utf8, @controller.params["abra"].first)

    # after filter のテスト(携帯電話に向けてsjisで送出しているか)
    @controller.response.body = @abracadabra_z_utf8
    filter.after(@controller)
    assert_equal('Shift_JIS', @controller.response.charset)
    assert_equal(@abracadabra_z_sjis, @controller.response.body)
  end

  def test_sjis_filter_for_jphone
    @controller.request = request_with_ua("J-PHONE/3.0/V401SH", "QUERY_STRING"=>"test=test&abra=%83A%83u%83%89%83J%83_%83u%83%89") # アブラカダブラ, Shift_JIS, urlencoded
    @controller.params = @controller.request.params

    # before filter のテスト(携帯電話からのパラメータがutf-8で格納されているか)
    filter = Jpmobile::Filter::Sjis.new
    filter.before(@controller)
    assert_equal(@abracadabra_z_utf8, @controller.params["abra"].first)

    # after filter のテスト(携帯電話に向けてsjisで送出しているか)
    @controller.response.body = @abracadabra_z_utf8
    filter.after(@controller)
    assert_equal('Shift_JIS', @controller.response.charset)
    assert_equal(@abracadabra_z_sjis, @controller.response.body)
  end

  def test_sjis_filter_does_not_work_for_vodafone
    # VodafoneにはShift_JIS変換を行わないことをテスト
    @controller.request = request_with_ua("Vodafone/1.0/V903T/TJ001 Browser/VF-Browser/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0", "QUERY_STRING"=>"test=test&abra=%83A%83u%83%89%83J%83_%83u%83%89") # アブラカダブラ, Shift_JIS, urlencoded
    @controller.params = @controller.request.params

    filter = Jpmobile::Filter::Sjis.new
    filter.before(@controller) # 実行しておかないとカウンタが狂う

    # after filter のテスト(携帯電話に向けてsjisで送出していないことを確認)
    filter.after(@controller)
    @controller.response.body = @abracadabra_z_utf8
    assert_not_equal('Shift_JIS', @controller.response.charset)
    assert_equal(@abracadabra_z_utf8, @controller.response.body)
  end

  def test_sjis_filter_does_not_work_for_softbank
    # VodafoneにはShift_JIS変換を行わないことをテスト
    @controller.request = request_with_ua("SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1", "QUERY_STRING"=>"test=test&abra=%83A%83u%83%89%83J%83_%83u%83%89") # アブラカダブラ, Shift_JIS, urlencoded
    @controller.params = @controller.request.params

    filter = Jpmobile::Filter::Sjis.new
    filter.before(@controller) # 実行しておかないとカウンタが狂う

    # after filter のテスト(携帯電話に向けてsjisで送出していないことを確認)
    filter.after(@controller)
    @controller.response.body = @abracadabra_z_utf8
    assert_not_equal('Shift_JIS', @controller.response.charset)
    assert_equal(@abracadabra_z_utf8, @controller.response.body)
  end
end

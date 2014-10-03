require 'rails_helper'

describe "jpmobile integration spec", :type => :feature do
  include Jpmobile::Util

  before do
    page.driver.header('User-Agent', user_agent)
  end

  shared_examples_for "hankaku_filter :input => true のとき" do
    it "はtextareaの中では半角に変換されないこと" do
      visit "/#{controller}/textarea"
      expect(page.body.encode('UTF-8')).to have_content('アブラカダブラ')
    end
    it "はinputのvalueの中では半角に変換されないこと" do
      visit "/#{controller}/input_tag"
      expect(page.body.encode('UTF-8')).to have_css('input[value="アブラカダブラ"]')
    end
    it "は&nbsp;変換されない" do
      visit "/#{controller}/nbsp_char"
      expect(page.body.encode('UTF-8')).to have_content('ｱﾌﾞﾗ ｶﾀﾞﾌﾞﾗ')
    end
  end

  shared_examples_for "hankaku_filter :input => false のとき" do
    it "はtextareaの中でも半角に変換されること" do
      visit "/#{controller}/textarea"
      expect(page.body.encode('UTF-8')).to have_content('ｱﾌﾞﾗｶﾀﾞﾌﾞﾗ')
    end
    it "はinputのvalueの中も半角に変換されること" do
      visit "/#{controller}/input_tag"
      expect(page.body.encode('UTF-8')).to have_css('input[value="ｱﾌﾞﾗｶﾀﾞﾌﾞﾗ"]')
    end
    it "は&nbsp;変換されない" do
      visit "/#{controller}/nbsp_char"
      expect(page.body.encode('UTF-8')).to have_content('ｱﾌﾞﾗ ｶﾀﾞﾌﾞﾗ')
    end
  end

  shared_examples_for "文字コードフィルタが動作しているとき" do
    it "はhtml以外は変換しないこと" do
      visit "/#{controller}/rawdata"
      expect(page.body.encode('UTF-8')).to have_content("アブラカダブラ")
      expect(page.response_headers['Content-Type']).not_to match(/charset/i)
    end
    it "response.bodyが空のときは文字コードを変更しないこと" do
      visit "/#{controller}/empty"
      expect(page.response_headers['Content-Type']).to match(/utf-8/i)
    end
  end

  shared_examples_for "Shift_JISで通信する端末との通信" do
    it "はShift_JISで携帯に送出されること" do
      visit "/#{controller}/abracadabra_utf8"
      expect(page.body.encode('UTF-8')).to have_content("アブラカダブラ")
      expect(page.response_headers['Content-Type']).to match(/Shift_JIS/i)
    end
    it "はxhtmlでもShift_JISで携帯に送出されること" do
      visit "/#{controller}/abracadabra_xhtml_utf8"

      expect(page.body.encode('UTF-8')).to have_content("アブラカダブラ")
      expect(page.response_headers['Content-Type']).to match(/Shift_JIS/i)
    end
    it "はShift_JISで渡されたパラメタがparamsにUTF-8に変換されて格納されること" do
      visit "/#{controller}/index_zenkaku?q=#{URI.escape(utf8_to_sjis("アブラカダブラ"))}"
      expect(page.body.encode('UTF-8')).to have_content('true')
    end
    it "は半角カナのparamsを変換しないこと" do
      # アブラカダブラ半角,SJIS
      visit "/#{controller}/index_hankaku?q=#{URI.escape(sjis("\261\314\336\327\266\300\336\314\336\327"))}"
      expect(page.body.encode('UTF-8')).to have_content('true')
    end
    it_should_behave_like "文字コードフィルタが動作しているとき"
  end

  shared_examples_for "UTF-8で通信する端末との通信" do
    it "はUTF-8で携帯に送出されること" do
      visit "/#{controller}/abracadabra_utf8"
      expect(page.body.encode('UTF-8')).to have_content("アブラカダブラ")
      expect(page.response_headers['Content-Type']).to match(/utf-8/i)
    end
    it "はxhtmlでもUTF-8で携帯に送出されること" do
      visit "/#{controller}/abracadabra_xhtml_utf8"
      expect(page.body.encode('UTF-8')).to have_content("アブラカダブラ")
      expect(page.response_headers['Content-Type']).to match(/utf-8/i)
    end
    it "はparamsにUTF-8のまま格納されること" do
      visit "/#{controller}/index_zenkaku?q=#{URI.escape("アブラカダブラ")}"
      expect(page.body.encode('UTF-8')).to have_content('true')
    end
    it "は半角カナのparamsを変換しないこと" do
      visit "/#{controller}/index_hankaku?q=#{URI.escape("ｱﾌﾞﾗｶﾀﾞﾌﾞﾗ")}"
      expect(page.body.encode('UTF-8')).to have_content('true')
    end
    it_should_behave_like "文字コードフィルタが動作しているとき"
  end

  shared_examples_for "Shift_JISで通信する端末との通信(半角変換付き)" do
    it "は半角に変換されShift_JISで携帯に送出されること" do
      visit "/#{controller}/abracadabra_utf8"
      expect(page.body.encode('UTF-8')).to have_content("ｱﾌﾞﾗｶﾀﾞﾌﾞﾗ") # アブラカダブラ半角,SJIS
      expect(page.response_headers['Content-Type']).to match(/Shift_JIS/)
    end
    it "はShift_JISで渡されたパラメタがparamsにUTF-8に変換されて格納されること" do
      visit "/#{controller}/index_zenkaku?q=#{URI.escape(utf8_to_sjis("アブラカダブラ"))}"
      expect(page.body.encode('UTF-8')).to have_content('true')
    end
    it "は半角Shift_JISで渡されたパラメタがparamsに全角UTF-8に変換されて格納されること" do
      # アブラカダブラ半角,SJIS
      visit "/#{controller}/index_zenkaku?q=#{URI.escape(sjis("\261\314\336\327\266\300\336\314\336\327"))}"
      expect(page.body.encode('UTF-8')).to have_content('true')
    end
    it_should_behave_like "文字コードフィルタが動作しているとき"
  end

  shared_examples_for "UTF-8で通信する端末との通信(半角変換付き)" do
    it "はUTF-8半角で携帯に送出されること" do
      visit "/#{controller}/abracadabra_utf8"
      expect(page.body.encode('UTF-8')).to have_content("ｱﾌﾞﾗｶﾀﾞﾌﾞﾗ")
      expect(page.response_headers['Content-Type']).to match(/utf-8/i)
    end
    it "はparamsにUTF-8のまま格納されること" do
      visit "/#{controller}/index_zenkaku?q=#{URI.escape("アブラカダブラ")}"
      expect(page.body.encode('UTF-8')).to have_content('true')
    end
    it "は半角で渡されたparamsを全角に変換して格納すること" do
      visit "/#{controller}/index_zenkaku?q=#{URI.escape("ｱﾌﾞﾗｶﾀﾞﾌﾞﾗ")}"
      expect(page.body.encode('UTF-8')).to have_content('true')
    end
    it_should_behave_like "文字コードフィルタが動作しているとき"
  end

  #
  # PCからのアクセス
  #
  describe FilterController do
    let(:controller) { "filter" }

    describe "PCからのアクセス" do
      let(:user_agent) {
        "Mozilla/5.0 (Windows; U; Windows NT 5.1; ja; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 ( .NET CLR 3.5.30729)"
      }
      it_should_behave_like "UTF-8で通信する端末との通信"
    end

    describe "DoCoMo SH902i からのアクセス" do
      let(:user_agent) {
        "DoCoMo/2.0 SH902i(c100;TB;W24H12)"
      }
      it_should_behave_like "Shift_JISで通信する端末との通信"
    end

    describe "au CA32 からのアクセス" do
      let(:user_agent) {
        "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0"
      }
      it_should_behave_like "Shift_JISで通信する端末との通信"
    end

    describe "Vodafone V903T からのアクセス" do
      let(:user_agent) {
        "Vodafone/1.0/V903T/TJ001 Browser/VF-Browser/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0"
      }
      it_should_behave_like "UTF-8で通信する端末との通信"
    end

    describe "SoftBank 910T からのアクセス" do
      let(:user_agent) {
        "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1"
      }
      it_should_behave_like "UTF-8で通信する端末との通信"
    end
  end

  describe HankakuFilterController do
    let(:controller) { "hankaku_filter" }

    describe "PCからのアクセス" do
      let(:user_agent) {
        "Mozilla/5.0 (Windows; U; Windows NT 5.1; ja; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 ( .NET CLR 3.5.30729)"
      }
      it_should_behave_like "UTF-8で通信する端末との通信"
    end

    describe "DoCoMo SH902i からのアクセス" do
      let(:user_agent) {
        "DoCoMo/2.0 SH902i(c100;TB;W24H12)"
      }

      it_should_behave_like "Shift_JISで通信する端末との通信(半角変換付き)"
      it_should_behave_like "hankaku_filter :input => false のとき"
    end

    describe "SoftBank 910T からのアクセス" do
      let(:user_agent) {
        "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1"
      }

      it_should_behave_like "UTF-8で通信する端末との通信(半角変換付き)"
      it_should_behave_like "hankaku_filter :input => false のとき"
    end
  end

  describe HankakuInputFilterController do
    let(:controller) { "hankaku_input_filter" }

    describe "DoCoMo SH902i からのアクセス" do
      let(:user_agent) {
        "DoCoMo/2.0 SH902i(c100;TB;W24H12)"
      }

      it_should_behave_like "Shift_JISで通信する端末との通信(半角変換付き)"
      it_should_behave_like "hankaku_filter :input => true のとき"

      it "Content-Type が Shift_JIS であること" do
        visit "/#{controller }/with_charset"
        expect(body).to match(/Shift_JIS/)
      end
    end

    describe "SoftBank 910T からのアクセス" do
      let(:user_agent) do
        "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1"
      end

      it_should_behave_like "UTF-8で通信する端末との通信(半角変換付き)"
      it_should_behave_like "hankaku_filter :input => true のとき"

      it "Content-Type が UTF-8 であること" do
        visit "/#{controller}/with_charset"
        expect(page.response_headers['Content-Type']).to match(/UTF-8/i)
      end
    end
  end
end

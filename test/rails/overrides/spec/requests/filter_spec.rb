require 'system_helper'

describe 'jpmobile integration spec', type: :request do
  include Jpmobile::Util

  before do
    page.driver.headers = { 'User-Agent' => user_agent }
  end

  shared_examples_for '文字コードフィルタが動作しているとき' do
    it 'はhtml以外は変換しないこと' do
      get "/#{controller}/rawdata", env: { 'HTTP_USER_AGENT' => user_agent }
      expect(response.body.encode('UTF-8')).to eq('アブラカダブラ')
      expect(response.headers['Content-Type']).not_to match(/charset/i)
    end
  end

  #
  # PCからのアクセス
  #
  describe FilterController do
    let(:controller) { 'filter' }

    describe 'PCからのアクセス' do
      let(:user_agent) do
        'Mozilla/5.0 (Windows; U; Windows NT 5.1; ja; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 ( .NET CLR 3.5.30729)'
      end
      it_should_behave_like '文字コードフィルタが動作しているとき'
    end

    describe 'DoCoMo SH902i からのアクセス' do
      let(:user_agent) do
        'DoCoMo/2.0 SH902i(c100;TB;W24H12)'
      end
      it_should_behave_like '文字コードフィルタが動作しているとき'
    end

    describe 'au CA32 からのアクセス' do
      let(:user_agent) do
        'KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0'
      end
      it_should_behave_like '文字コードフィルタが動作しているとき'
    end

    describe 'Vodafone V903T からのアクセス' do
      let(:user_agent) do
        'Vodafone/1.0/V903T/TJ001 Browser/VF-Browser/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Ext-J-Profile/JSCL-1.2.2 Ext-V-Profile/VSCL-2.0.0'
      end
      it_should_behave_like '文字コードフィルタが動作しているとき'
    end

    describe 'SoftBank 910T からのアクセス' do
      let(:user_agent) do
        'SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1'
      end
      it_should_behave_like '文字コードフィルタが動作しているとき'
    end
  end

  describe HankakuFilterController do
    let(:controller) { 'hankaku_filter' }

    describe 'PCからのアクセス' do
      let(:user_agent) do
        'Mozilla/5.0 (Windows; U; Windows NT 5.1; ja; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 ( .NET CLR 3.5.30729)'
      end
      it_should_behave_like '文字コードフィルタが動作しているとき'
    end

    describe 'DoCoMo SH902i からのアクセス' do
      let(:user_agent) do
        'DoCoMo/2.0 SH902i(c100;TB;W24H12)'
      end

      it_should_behave_like '文字コードフィルタが動作しているとき'
    end

    describe 'SoftBank 910T からのアクセス' do
      let(:user_agent) do
        'SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1'
      end

      it_should_behave_like '文字コードフィルタが動作しているとき'
    end
  end

  describe HankakuInputFilterController do
    let(:controller) { 'hankaku_input_filter' }

    describe 'DoCoMo SH902i からのアクセス' do
      let(:user_agent) do
        'DoCoMo/2.0 SH902i(c100;TB;W24H12)'
      end

      it_should_behave_like '文字コードフィルタが動作しているとき'
    end

    describe 'SoftBank 910T からのアクセス' do
      let(:user_agent) do
        'SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1'
      end

      it_should_behave_like '文字コードフィルタが動作しているとき'
    end
  end
end

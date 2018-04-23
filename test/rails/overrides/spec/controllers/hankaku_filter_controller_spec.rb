require 'rails_helper'

describe Jpmobile::HankakuFilterController, type: :controller do
  describe '#index' do
    let(:params) { { prefecture_ids: ['1', '2'] } }

    it 'should be successful' do
      request.user_agent = 'DoCoMo/2.0 P05C(c500;TB;W24H16)'
      get 'index', params: params
      expect(response).to be_successful
      expect(request.mobile?).to be_truthy
    end
  end
end

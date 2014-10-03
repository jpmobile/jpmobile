require 'rails_helper'

describe DecoratedMailer, :type => :mailer do
  include Jpmobile::Util

  before(:each) do
    ActionMailer::Base.deliveries = []
  end

  shared_examples_for "content-type" do
    it "sends decorated mail successfully" do
      DecoratedMailer.deco_mail(@to).deliver_now

      email = ActionMailer::Base.deliveries.first
      expect(email.header['Content-Type'].main_type).to eq('multipart')
      expect(email.header['Content-Type'].sub_type).to eq('mixed')
    end
  end

  describe "docomo" do
    before(:each) do
      @to = "docomo@docomo.ne.jp"
    end

    it_behaves_like "content-type"
  end

  describe "au" do
    before(:each) do
      @to = "au@ezweb.ne.jp"
    end

    it_behaves_like "content-type"
  end

  describe "softbank" do
    before(:each) do
      @to = "softbank@softbank.ne.jp"
    end

    it_behaves_like "content-type"
  end
end

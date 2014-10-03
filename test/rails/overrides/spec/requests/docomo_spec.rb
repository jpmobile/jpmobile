require 'rails_helper'

describe "DoCoMo SH902i からのアクセス", :type => :request do
  it "request.mobile は Docomo のインスタンスであるべき" do
    get "/mobile_spec/index", {}, {"HTTP_USER_AGENT" => "DoCoMo/2.0 SH902i(c100;TB;W24H12)"}

    expect(request.mobile).to be_an_instance_of(Jpmobile::Mobile::Docomo)
  end
  it "request.mobile? は true であるべき" do
    get "/mobile_spec/index", {}, {"HTTP_USER_AGENT" => "DoCoMo/2.0 SH902i(c100;TB;W24H12)"}

    expect(request.mobile?).to be_truthy
  end
end

describe "DoCoMo SH902i からguid付きのアクセス", :type => :request do
  before(:each) do
    @headers = {"HTTP_USER_AGENT" => "DoCoMo/2.0 SH902i(c100;TB;W24H12)", 'HTTP_X_DCMGUID' => "000000a"}
  end

  it "guidを正しく取得できること" do
    get "/mobile_spec/index", {}, @headers

    expect(request.mobile.guid).to eq("000000a")
  end
  it "ident_subscriberでも正しく取得できること" do
    get "/mobile_spec/index", {}, @headers

    expect(request.mobile.ident_subscriber).to eq("000000a")
  end
end

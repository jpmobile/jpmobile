require 'rails_helper'

describe "Softbank Emulator からのアクセスのとき", :type => :request do
  it "request.mobile は Softbank のインスタンスであること" do
    get "/mobile_spec/index", {}, {"HTTP_USER_AGENT" => "Semulator"}

    expect(request.mobile).to be_an_instance_of(Jpmobile::Mobile::Softbank)
    expect(request.mobile?).to be_truthy
  end
end

describe "Vodafone Emulator からのアクセスのとき", :type => :request do
  it "request.mobile は Vodafone のインスタンスであること" do
    get "/mobile_spec/index", {}, {"HTTP_USER_AGENT" => "Vemulator"}

    expect(request.mobile).to be_an_instance_of(Jpmobile::Mobile::Vodafone)
    expect(request.mobile?).to be_truthy
  end
end

require 'action_view'
require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))
require 'jpmobile/hook_template_details_requested'
require 'jpmobile/template_details'

describe Jpmobile::HookTemplateDetailsRequested do
  let(:requested_class) do
    Class.new(ActionView::TemplateDetails::Requested).tap do |klass|
      klass.prepend(described_class)
    end
  end

  let(:requested) do
    requested_class.new(
      locale: [:en],
      handlers: [:erb],
      formats: [:html],
      variants: [:default],
      mobile: ['tablet', 'smart_phone'],
    )
  end

  it 'mobile を Symbol 配列に変換し、Symbol キーの index を構築すること' do
    expect(requested.mobile).to eq(%i[tablet smart_phone])
    expect(requested.mobile_idx).to include(tablet: 0, smart_phone: 1)
  end

  it 'TemplateDetails の検索で mobile variant の index を引けること' do
    template_details = Jpmobile::TemplateDetails.new(:en, :erb, :html, :default, :smart_phone)

    expect(template_details.matches?(requested)).to be_truthy
    expect(template_details.sort_key_for(requested)).to eq([0, 0, 0, 1, 0])
  end

  it 'mobile を指定しない TemplateDetails が汎用テンプレートとして最後に一致すること' do
    template_details = Jpmobile::TemplateDetails.new(:en, :erb, :html, :default, nil)

    expect(template_details.matches?(requested)).to be_truthy
    expect(template_details.sort_key_for(requested)).to eq([0, 0, 0, 2, 0])
  end

  it '要求されていない mobile variant の TemplateDetails は一致しないこと' do
    template_details = Jpmobile::TemplateDetails.new(:en, :erb, :html, :default, :iphone)

    expect(template_details.matches?(requested)).to be_falsey
  end
end

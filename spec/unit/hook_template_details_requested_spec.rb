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
    aggregate_failures do
      expect(requested.mobile).to eq(%i[tablet smart_phone])
      expect(requested.mobile_idx.keys).to eq(%i[tablet smart_phone] + [nil])
    end
  end

  it 'TemplateDetails の検索で mobile variant の index を引けること' do
    template_details = Jpmobile::TemplateDetails.new(:en, :erb, :html, :default, :tablet)

    expect(template_details.matches?(requested)).to eq(0)
    expect(template_details.sort_key_for(requested)).to eq([0, 0, 0, 0, 0])
  end
end

require 'action_view'
require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))
require 'jpmobile/template_details'

describe Jpmobile::TemplateDetails::Requested do
  it 'mobile variant の順序を検索用 index に反映すること' do
    requested = described_class.new(
      locale: [:en],
      handlers: [:erb],
      formats: [:html],
      variants: [nil],
      mobile: [:tablet, :smart_phone],
    )

    expect(requested.mobile).to eq(%i[tablet smart_phone])
    expect(requested.mobile_idx).to include(tablet: 0, smart_phone: 1)
  end
end

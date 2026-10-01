require 'action_view'
require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))
require 'jpmobile/template_details'

describe Jpmobile::TemplateDetails::Requested do
  it 'mobile に渡された variant を Symbol の配列に正規化すること' do
    requested = described_class.new(
      locale: [:en],
      handlers: [:erb],
      formats: [:html],
      variants: [nil],
      mobile: ['tablet', 'smart_phone'],
    )

    expect(requested.mobile).to eq(%i[tablet smart_phone])
  end
end

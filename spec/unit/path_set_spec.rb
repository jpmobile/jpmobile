require 'action_view'
require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

describe Jpmobile::PathSet do
  it 'Resolver をそのまま保持すること' do
    resolver = Jpmobile::Resolver.new('/tmp/views')

    expect(described_class.new([resolver]).paths).to eq([resolver])
  end

  it '文字列のパスを Jpmobile::Resolver に変換すること' do
    paths = described_class.new(['/tmp/views']).paths

    expect(paths).to contain_exactly(an_instance_of(Jpmobile::Resolver))
  end

  it '不正な型には親と同じ TypeError を送出すること' do
    parent_error = begin
      ActionView::PathSet.new([1])
    rescue TypeError => e
      e
    end

    expect { described_class.new([1]) }.to raise_error(TypeError, parent_error.message)
  end
end

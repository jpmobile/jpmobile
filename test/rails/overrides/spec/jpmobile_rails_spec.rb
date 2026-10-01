require 'rails_helper'

describe 'Jpmobile Rails hooks' do
  it 'テスト環境以外では test request hook を読み込まないこと' do
    hook = ActiveSupport.instance_variable_get(:@load_hooks).
             fetch(:action_controller).
             map(&:first).
             find {|block| block.source_location&.first&.end_with?('/lib/jpmobile/rails.rb') }

    expect(hook).not_to be_nil
    allow(Rails).to receive(:env).and_return(ActiveSupport::EnvironmentInquirer.new('production'))
    expect(ActionController::Base).not_to receive(:require).with('jpmobile/hook_test_request')

    ActionController::Base.class_eval(&hook)
  end
end

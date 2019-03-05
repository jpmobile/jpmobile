#:stopdoc:
# helperを追加
# ActionView で trans_sid を有効にする
ActionView::Base.class_eval do
  include Jpmobile::Helpers

  delegate :default_url_options, to: :controller unless respond_to?(:default_url_options)
end
#:startdoc:

# :stopdoc:
# accept-charset に charset を変更できるようにする
module Jpmobile
  module ActionView
    module HtmlOptionsWithAcceptCharset
      private

      def html_options_for_form(url_for_options, options, *parameters_for_url)
        super.tap do |o|
          o['accept-charset'] = (Rails.application.config.jpmobile.form_accept_charset_conversion && request && request.mobile && request.mobile.default_charset) || o['accept-charset']
        end
      end
    end
  end
end

::ActionView::Helpers::FormTagHelper.send :prepend, Jpmobile::ActionView::HtmlOptionsWithAcceptCharset
#:startdoc:

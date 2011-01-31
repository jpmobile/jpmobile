# -*- coding: utf-8 -*-
#:stopdoc:
# helperを追加
ActionView::Base.class_eval { include Jpmobile::Helpers }
#:startdoc:

# :stopdoc:
# accept-charset に charset を変更できるようにする
# ActionView で trans_sid を有効にする
module ActionView
  module Helpers
    module FormTagHelper
      private
      def html_options_for_form(url_for_options, options, *parameters_for_url)
        accept_charset = (Rails.application.config.jpmobile.form_accept_charset_conversion && request && request.mobile && request.mobile.default_charset) || "UTF-8"

        options.stringify_keys.tap do |html_options|
          html_options["enctype"] = "multipart/form-data" if html_options.delete("multipart")
          # The following URL is unescaped, this is just a hash of options, and it is the
          # responsability of the caller to escape all the values.
          html_options["action"]  = url_for(url_for_options, *parameters_for_url)
          html_options["accept-charset"] = accept_charset
          html_options["data-remote"] = true if html_options.delete("remote")
        end
      end
    end
  end

  class Base
    delegate :default_url_options, :to => :controller unless respond_to?(:default_url_options)
  end
end
#:startdoc:

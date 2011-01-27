# -*- coding: utf-8 -*-
require 'jpmobile/mail'

module Jpmobile
  module Mailer
    class Base < ActionMailer::Base
      def mail(headers={}, &block)
        m = super(headers, &block)

        @mobile = if m.to.size == 1
                    # for mobile
                    (Jpmobile::Email.detect(m.to.first) || Jpmobile::Mobile::AbstractMobile).new(nil, nil)
                  else
                    # for multi to addresses
                    Jpmobile::Mobile::AbstractMobile.new(nil, nil)
                  end
        m.mobile  = @mobile
        m.charset = @mobile.mail_charset

        m
      end
    end
  end
end

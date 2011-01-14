# -*- coding: utf-8 -*-
require 'jpmobile/mail'

module Jpmobile
  module Mailer
    class Base < ActionMailer::Base
      def mail(headers={}, &block)
        m = super(headers, &block)

        if m.to.size == 1
          # for mobile
          m.mobile = (Jpmobile::Email.detect(m.to.first) || Jpmobile::Mobile::AbstractMobile).new(nil, nil)
        else
          # for multi to addresses
          m.mobile = Jpmobile::Mobile::AbstractMobile.new(nil, nil)
        end

        m
      end
    end
  end
end

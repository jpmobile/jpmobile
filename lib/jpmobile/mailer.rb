# -*- coding: utf-8 -*-
require 'jpmobile/mail'
require 'jpmobile/lookup_context'

Jpmobile::Email.japanese_mail_address_regexp = Regexp.new(/\.jp[^a-zA-Z\.\-]/)

module Jpmobile
  module Mailer
    class Base < ActionMailer::Base
      self._view_paths = self._view_paths.dup
      self.view_paths.unshift(Jpmobile::Resolver.new(File.join(::Rails.root, "app/views")))

      def mail(headers={}, &block)
        tos = headers[:to] || self.default_params[:to]
        tos = tos.split(/,/)

        @mobile = if tos.size == 1
                    # for mobile
                    (Jpmobile::Email.detect(tos.first) || Jpmobile::Mobile::AbstractMobile).new(nil, nil)
                  else
                    # for multi to addresses
                    Jpmobile::Mobile::AbstractMobile.new(nil, nil)
                  end
        self.lookup_context.mobile = @mobile.variants

        m = super(headers, &block)

        m.mobile  = @mobile
        m.charset = @mobile.mail_charset

        m
      end

      class << self
        protected
        def set_payload_for_mail(payload, mail) #:nodoc:
          super

          payload[:mail] = Jpmobile::Util.ascii_8bit(mail.encoded).gsub(/\r\n/, "\n")
        end
      end
    end
  end
end

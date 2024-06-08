require 'jpmobile/mail'
require 'jpmobile/lookup_context'

Jpmobile::Email.japanese_mail_address_regexp = /\.jp(?:[^a-zA-Z.-]|$)/

module Jpmobile
  module Mailer
    class Base < ActionMailer::Base
      self.prepend_view_path(Jpmobile::Resolver.new(File.join(::Rails.root, 'app/views')))

      def mail(headers = {}, &)
        tos = headers[:to] || self.default_params[:to]
        tos = tos.split(',')

        @mobile = if tos.size == 1
                    # for mobile
                    (Jpmobile::Email.detect(tos.first) || Jpmobile::Mobile::AbstractMobile).new(nil, nil)
                  else
                    # for multi to addresses
                    Jpmobile::Mobile::AbstractMobile.new(nil, nil)
                  end
        self.lookup_context.mobile = @mobile.mail_variants

        @mobile.decorated = headers.delete(:decorated)

        m = super

        m.mobile = @mobile

        # for decorated-mail manipulation
        m.rearrange! if @mobile.decorated?

        m
      end

      class << self
        protected

        def set_payload_for_mail(payload, mail) # :nodoc:
          super

          payload[:mail] = Jpmobile::Util.ascii_8bit(mail.encoded).gsub("\r\n", "\n")
        end
      end
    end
  end
end

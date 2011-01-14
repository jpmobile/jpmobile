# -*- coding: utf-8 -*-
require 'mail'

module Mail
  # encoding patch
  if self.const_defined?(:Ruby19)
    Ruby19.class_eval do
      def self.b_value_decode(str)
        match = str.match(/\=\?(.+)?\?[Bb]\?(.+)?\?\=/m)
        if match
          encoding = match[1]
          str = self.decode_base64(match[2])
          str.force_encoding(fix_encoding(encoding))
        end
        str
      end
    end
  end

  class Message
    attr_accessor :mobile

    def mobile=(m)
      @mobile = m
    end

    def encoded_with_jpmobile
      if @mobile
        header['subject'].mobile = @mobile
        self.charset             = @mobile.mail_charset

        ready_to_send!
        @body.mobile = @mobile
        header['Content-Transfer-Encoding'] = '8bit'

        buffer = header.encoded
        buffer << "\r\n"
        buffer = @mobile.utf8_to_mail_encode(buffer)
        buffer << body.encoded(content_transfer_encoding)
        buffer
      else
        encoded_without_jpmobile
      end
    end

    alias_method :encoded_without_jpmobile, :encoded
    alias_method :encoded, :encoded_with_jpmobile
  end

  class Body
    attr_accessor :mobile

    # convert encoding
    def encoded_with_jpmobile(transfer_encoding = '8bit')
      if @mobile and !multipart?
        @mobile.to_mail_body(raw_source)
      else
        encoded_without_jpmobile(transfer_encoding)
      end
    end

    alias_method :encoded_without_jpmobile, :encoded
    alias_method :encoded, :encoded_with_jpmobile
  end

  class UnstructuredField
    attr_accessor :mobile
  end

  # for subject
  class SubjectField < UnstructuredField
    # not folding subject
    def encoded_with_jpmobile
      if @mobile
        # convert encoding
        "#{name}: " + @mobile.to_mail_subject(value) + "\r\n"
      else
        encoded_without_jpmobile
      end
    end

    alias_method :encoded_without_jpmobile, :encoded
    alias_method :encoded, :encoded_with_jpmobile
  end
end

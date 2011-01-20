# -*- coding: utf-8 -*-
require 'mail'

module Jpmobile
  module Mail
    module_function
  end
end

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
        # if str contains some emoticon, the following line raises Encoding error
        str.encode("utf-8", :invalid => :replace, :replace => "") rescue Jpmobile::Util.ascii_8bit(str)
      end
    end
  elsif self.const_defined?(:Ruby18)
    Ruby18.class_eval do
      def self.b_value_decode(str)
        match = str.match(/\=\?(.+)?\?[Bb]\?(.+)?\?\=/m)
        if match
          encoding = match[1]
          str = Ruby18.decode_base64(match[2])
        end
        str
      end
    end
  end

  class Message
    attr_accessor :mobile

    def encoded_with_jpmobile
      if @mobile
        header['subject'].mobile = @mobile if header['subject']
        self.charset             = @mobile.mail_charset

        ready_to_send!

        self.body.mobile = @mobile
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

    def parse_message_with_jpmobile
      parse_message_without_jpmobile

      if !multipart? and self.header['Content-Type']
        self.body.charset = case self.header['Content-Type'].value
                            when /iso-2022-jp/i
                              "ISO-2022-JP"
                            when /shift_jis/i
                              "Shift_JIS"
                            else
                              "UTF-8"
                            end
      end
      self.header['subject'].mobile = @mobile if self.header['subject']
    end

    def init_with_string_with_jpmobile(string)
      # Jpmobile::Mobile class from 'From: ' header
      s = Jpmobile::Util.ascii_8bit(string)

      mobile_class = nil
      content_has_from = false
      s.split(/\n|\r/).each do |line|
        if line =~ /^From:/
          content_has_from = true
          break if mobile_class = Jpmobile::Email.detect_from_mail_header(line)
        end
      end

      if content_has_from
        @mobile = (mobile_class || Jpmobile::Mobile::AbstractMobile).new(nil, nil)

        init_with_string_without_jpmobile(s)

        self.body.mobile = @mobile
        self.body.set_encoding_jpmobile
        if self.body.multipart?
          self.body.parts.each do |part|
            part.body.mobile = @mobile
            part.body.set_encoding_jpmobile
          end
        end
      else
        init_with_string_without_jpmobile(s)
      end
    end

    def process_body_raw_with_jpmobile
      process_body_raw_without_jpmobile

      self.body.mobile = @mobile
    end

    alias_method :encoded_without_jpmobile, :encoded
    alias_method :encoded, :encoded_with_jpmobile

    alias_method :parse_message_without_jpmobile, :parse_message
    alias_method :parse_message, :parse_message_with_jpmobile

    alias_method :init_with_string_without_jpmobile, :init_with_string
    alias_method :init_with_string, :init_with_string_with_jpmobile

    alias_method :process_body_raw_without_jpmobile, :process_body_raw
    alias_method :process_body_raw, :process_body_raw_with_jpmobile
  end

  class Part
    def parse_message_with_jpmobile
      parse_message_without_jpmobile

      if !multipart? and self.header['Content-Type']
        @charset = case self.header['Content-Type'].value
                   when /iso-2022-jp/i
                     "ISO-2022-JP"
                   when /shift_jis/i
                     "Shift_JIS"
                   else
                     "UTF-8"
                   end
        self.body.charset = @charset
      end
    end

    alias_method :parse_message_without_jpmobile, :parse_message
    alias_method :parse_message, :parse_message_with_jpmobile
  end

  class Body
    attr_accessor :mobile

    # convert encoding
    def encoded_with_jpmobile(transfer_encoding = '8bit')
      if @mobile and !multipart?
        if @mobile.to_mail_body_encoded?(raw_source)
          raw_source
        else
          @mobile.to_mail_body(Jpmobile::Util.force_encode(raw_source, @charset, Jpmobile::Util::UTF8))
        end
      else
        encoded_without_jpmobile(transfer_encoding)
      end
    end
    def decoded_with_jpmobile
      if @mobile and !multipart?
        @raw_source = @mobile.to_mail_internal(@raw_source, nil) unless @jpmobile_decoded
        @jpmobile_decoded = true
      end

      if @charset
        @raw_source = Jpmobile::Util.force_encode(@raw_source, @charset, Jpmobile::Util::UTF8)
      end

      decoded_without_jpmobile
    end

    # fix charset
    def set_charset_with_jpmobile
      @charset ||= only_us_ascii? ? 'US-ASCII' : nil
    end

    # set encoding to @raw_source in init
    def set_encoding_jpmobile
      @raw_source = Jpmobile::Util.set_encoding(@raw_source, @charset)
    end

    def mobile=(m)
      if self.multipart?
        self.parts.each do |part|
          part.body.mobile = @mobile
          part.body.set_encoding_jpmobile
        end
      end

      @mobile = m
      self.set_encoding_jpmobile
    end

    alias_method :encoded_without_jpmobile, :encoded
    alias_method :encoded, :encoded_with_jpmobile

    alias_method :decoded_without_jpmobile, :decoded
    alias_method :decoded, :decoded_with_jpmobile

    alias_method :set_charset_without_jpmobile, :set_charset
    alias_method :set_charset, :set_charset_with_jpmobile
  end

  class UnstructuredField
    attr_accessor :mobile

    def do_decode
      result = value.blank? ? nil : Encodings.decode_encode(value, :decode)

      result = @mobile.to_mail_internal(result, value) if @mobile

      # result.encode!(value.encoding || "UTF-8") if RUBY_VERSION >= '1.9' && !result.blank?
      result.blank? ? result : Jpmobile::Util.force_encode(result, nil, Jpmobile::Util::UTF8)
    end
  end

  # for subject
  class SubjectField < UnstructuredField
    # FIXME: not folding subject -> folding
    def encoded_with_jpmobile
      if @mobile
        if @mobile.to_mail_subject_encoded?(value)
          "#{name}: #{value}\r\n"
        else
          # convert encoding
          "#{name}: " + @mobile.to_mail_subject(value) + "\r\n"
        end
      else
        encoded_without_jpmobile
      end
    end

    # def decoded_with_jpmobile
    #   decoded_without_jpmobile
    # end

    alias_method :encoded_without_jpmobile, :encoded
    alias_method :encoded, :encoded_with_jpmobile

    # alias_method :decoded_without_jpmobile, :decoded
    # alias_method :decoded, :decoded_with_jpmobile
  end
end

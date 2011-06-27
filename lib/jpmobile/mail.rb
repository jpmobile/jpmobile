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
        # if str contains some emoticon, the following line raises Encoding error
        str.encode("utf-8", :invalid => :replace, :replace => "") rescue Jpmobile::Util.ascii_8bit(str)
      end

      # change encoding
      def self.b_value_encode(str, encoding)
        str = Jpmobile::Util.encode(str, encoding)
        [Ruby19.encode_base64(str), encoding]
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

      # change encoding
      def self.b_value_encode(str, encoding)
        str = Jpmobile::Util.encode(str, encoding)
        [Encodings::Base64.encode(str), encoding]
      end
    end
  end

  class Message
    attr_accessor :mobile

    def mobile=(m)
      if @mobile = m
        @charset = m.mail_charset(@charset)

        if @body
          @body.charset = @charset
          @body.mobile = m
        end
      end
    end

    def encoded_with_jpmobile
      if @mobile
        header['subject'].mobile = @mobile if header['subject']
        header['from'].mobile    = @mobile if header['from']
        header['to'].mobile      = @mobile if header['to']
        self.charset             = @mobile.mail_charset(@charset)

        ready_to_send!

        self.body.charset = @charset
        self.body.mobile  = @mobile
        self.header['Content-Transfer-Encoding'] = '8bit'

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
      header_part, body_part = raw_source.split(/#{CRLF}#{WSP}*#{CRLF}/m, 2)

      self.header = header_part

      @body_part_jpmobile = body_part
      convert_encoding_jpmobile
      body_part = @body_part_jpmobile

      self.body   = body_part
    end

    def init_with_string(string)
      # convert to ASCII-8BIT for ascii incompatible encodings
      s = Jpmobile::Util.ascii_8bit(string)
      self.raw_source = s
      set_envelope_header
      parse_message
      @separate_parts = multipart?
    end

    def process_body_raw_with_jpmobile
      process_body_raw_without_jpmobile

      if @mobile
        @body.charset = @charset
        @body.mobile = @mobile

        if has_content_transfer_encoding? and
            ["base64", "quoted-printable"].include?(content_transfer_encoding) and
            ["text"].include?(@mobile_main_type)
          @body.decode_transfer_encoding
        end

        if @body.multipart?
          @body.parts.each do |p|
            p.charset = @charset
            p.mobile = @mobile
          end
        end
      end
    end

    def body_lazy_with_jpmobile(value, index)
      body_lazy_without_jpmobile(value, index)
    end

    alias_method :encoded_without_jpmobile, :encoded
    alias_method :encoded, :encoded_with_jpmobile

    alias_method :parse_message_without_jpmobile, :parse_message
    alias_method :parse_message, :parse_message_with_jpmobile

    alias_method :process_body_raw_without_jpmobile, :process_body_raw
    alias_method :process_body_raw, :process_body_raw_with_jpmobile

    alias_method :body_lazy_without_jpmobile, :body_lazy
    alias_method :body_lazy, :body_lazy_with_jpmobile

    private
    def convert_encoding_jpmobile
      # decide mobile carrier
      if self.header[:from]
        mobile_class = Jpmobile::Email.detect_from_mail_header(self.header[:from].value)
        @mobile ||= mobile_class.new(nil, nil) if mobile_class
      end

      # override charset
      if self.header[:content_type]
        content_type_charset = Jpmobile::Util.extract_charset(self.header[:content_type].value)
        unless content_type_charset.blank?
          @charset = content_type_charset
          self.header[:content_type].parameters[:charset] = @charset
          @mobile_main_type = self.header[:content_type].main_type
        end

        if !Jpmobile::Email.convertable?(self.header[:content_type].value) and content_type_charset.blank?
          @charset = ''
        end
      end

      # convert header(s)
      if self.header[:subject]
        subject_charset = Jpmobile::Util.extract_charset(self.header[:subject].value)

        # override subject encoding if @charset is blank
        @charset = subject_charset if !subject_charset.blank? # and @charset.blank?
        self.header[:subject].charset = subject_charset unless subject_charset.blank?

        if @mobile
          v = @mobile.to_mail_internal(
            Encodings.value_decode(self.header[:subject].value), subject_charset)
          if @charset == subject_charset and @mobile.mail_charset != @charset
            self.header[:subject].value = Jpmobile::Util.force_encode(v, @charset, Jpmobile::Util::UTF8)
          else
            self.header[:subject].value = Jpmobile::Util.force_encode(v, @mobile.mail_charset(@charset), Jpmobile::Util::UTF8)
          end
        end
      end

      if @body_part_jpmobile and @mobile
        @body_part_jpmobile = @mobile.decode_transfer_encoding(@body_part_jpmobile, @charset)
      end
    end
  end

  class Part
    def init_with_string(string)
      self.raw_source = string
      set_envelope_header
      parse_message
      @separate_parts = multipart?
    end

    def parse_message_with_jpmobile
      header_part, body_part = raw_source.split(/#{CRLF}#{WSP}*#{CRLF}/m, 2)

      if header_part =~ HEADER_LINE
        self.header = header_part
      else
        self.header = "Content-Type: text/plain\r\n"
      end

      @body_part_jpmobile = body_part
      convert_encoding_jpmobile
      body_part = @body_part_jpmobile
      self.body   = body_part
    end

    alias_method :parse_message_without_jpmobile, :parse_message
    alias_method :parse_message, :parse_message_with_jpmobile
  end

  class Body
    attr_accessor :mobile

    # convert encoding
    def encoded_with_jpmobile(transfer_encoding = '8bit')
      if @mobile and !multipart?
        if @mobile.to_mail_body_encoded?(@raw_source)
          @raw_source
        else
          @mobile.to_mail_body(Jpmobile::Util.force_encode(@raw_source, @charset, Jpmobile::Util::UTF8))
        end
      else
        encoded_without_jpmobile(transfer_encoding)
      end
    end

    def decoded_with_jpmobile
      decoded_without_jpmobile
    end

    # fix charset
    def set_charset_with_jpmobile
      @charset ||= only_us_ascii? ? 'US-ASCII' : nil
    end

    def mobile=(m)
      @mobile = m

      if self.multipart? and @mobile
        self.parts.each do |part|
          part.charset      = @charset
          part.mobile       = @mobile
          part.body.charset = @charset
          part.body.mobile  = @mobile
        end
      end
    end

    def decode_transfer_encoding
      _raw_source = Encodings.get_encoding(encoding).decode(@raw_source)
      unless Jpmobile::Util.extract_charset(_raw_source) == @charset
        @charset = Jpmobile::Util.extract_charset(_raw_source)
      end
      _raw_source = Jpmobile::Util.set_encoding(_raw_source, @charset)
      @raw_source = @mobile.decode_transfer_encoding(_raw_source, @charset)
    end

    def preamble_with_jpmobile
      if @mobile
        Jpmobile::Util.encode(@preamble, @charset)
      else
        preamble_without_jpmobile
      end
    end

    def epilogue_with_jpmobile
      if @mobile
        Jpmobile::Util.encode(@epilogue, @charset)
      else
        epilogue_without_jpmobile
      end
    end

    def crlf_boundary_with_jpmobile
      if @mobile
        Jpmobile::Util.encode(crlf_boundary_without_jpmobile, @charset)
      else
        epilogue_without_jpmobile
      end
    end

    def end_boundary_with_jpmobile
      if @mobile
        Jpmobile::Util.encode(end_boundary_without_jpmobile, @charset)
      else
        epilogue_without_jpmobile
      end
    end

    alias_method :encoded_without_jpmobile, :encoded
    alias_method :encoded, :encoded_with_jpmobile

    alias_method :decoded_without_jpmobile, :decoded
    alias_method :decoded, :decoded_with_jpmobile

    alias_method :set_charset_without_jpmobile, :set_charset
    alias_method :set_charset, :set_charset_with_jpmobile

    alias_method :preamble_without_jpmobile, :preamble
    alias_method :preamble, :preamble_with_jpmobile

    alias_method :crlf_boundary_without_jpmobile, :crlf_boundary
    alias_method :crlf_boundary, :crlf_boundary_with_jpmobile

    alias_method :end_boundary_without_jpmobile, :end_boundary
    alias_method :end_boundary, :end_boundary_with_jpmobile

    alias_method :epilogue_without_jpmobile, :epilogue
    alias_method :epilogue, :epilogue_with_jpmobile
  end

  class UnstructuredField
    attr_accessor :mobile
  end

  # for subject
  class SubjectField < UnstructuredField
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

    alias_method :encoded_without_jpmobile, :encoded
    alias_method :encoded, :encoded_with_jpmobile
  end

  class StructuredField
    attr_accessor :mobile
  end

  class FromField < StructuredField
    def initialize_with_jpmobile(value = nil, charset = 'utf-8')
      @jpmobile_raw_text = value
      initialize_without_jpmobile(value, charset)
    end

    alias_method :initialize_without_jpmobile, :initialize
    alias_method :initialize, :initialize_with_jpmobile

    def mobile=(m)
      if @mobile = m
        self.charset = @mobile.mail_charset(@charset)
        self.value = @jpmobile_raw_text
        self.parse
      end
    end

    def encoded_with_jpmobile
      if @mobile
        self.charset = @mobile.mail_charset(@charset)
      end

      encoded_without_jpmobile
    end

    alias_method :encoded_without_jpmobile, :encoded
    alias_method :encoded, :encoded_with_jpmobile
  end

  class ToField < StructuredField
    def initialize_with_jpmobile(value = nil, charset = 'utf-8')
      @jpmobile_raw_text = value
      initialize_without_jpmobile(value, charset)
    end

    alias_method :initialize_without_jpmobile, :initialize
    alias_method :initialize, :initialize_with_jpmobile

    def mobile=(m)
      if @mobile = m
        self.charset = @mobile.mail_charset(@charset)
        self.value = @jpmobile_raw_text
        self.parse
      end
    end

    def encoded_with_jpmobile
      if @mobile
        self.charset = @mobile.mail_charset(@charset)
      end

      encoded_without_jpmobile
    end

    alias_method :encoded_without_jpmobile, :encoded
    alias_method :encoded, :encoded_with_jpmobile
  end

  class Address
    def encoded_with_jpmobile
      encoded_without_jpmobile
    end

    alias_method :encoded_without_jpmobile, :encoded
    alias_method :encoded, :encoded_with_jpmobile
  end

  class Sendmail
    def Sendmail.call(path, arguments, destinations, mail)
      encoded_mail = mail.encoded
      if Jpmobile::Util.jis?(encoded_mail)
        encoded_mail = Jpmobile::Util.ascii_8bit(encoded_mail)
      end

      IO.popen("#{path} #{arguments} #{destinations}", "w+") do |io|
        io.puts encoded_mail.gsub(/\r\r\n/, "\n").to_lf
        io.flush
      end
    end
  end
end

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

        if self.body
          self.body.content_type_with_jpmobile = self.content_type
          self.body.charset = @charset
          self.body.mobile = m
        end
      end
    end

    def encoded_with_jpmobile
      if @mobile
        header['subject'].mobile = @mobile if header['subject']
        header['from'].mobile    = @mobile if header['from']
        header['to'].mobile      = @mobile if header['to']
        self.charset             = @mobile.mail_charset

        ready_to_send!

        self.body.charset = @charset
        self.body.mobile  = @mobile
        self.header['Content-Transfer-Encoding'].value = @mobile.content_transfer_encoding(self.header)
        if @mobile.decorated?
          unless self.content_type.match(/image\//)
            self.header['Content-ID'] = nil
          end

          unless self.header['Content-Type'].sub_type == 'mixed'
            self.header['Date']         = nil
            self.header['Mime-Version'] = nil
          end
        end

        buffer = header.encoded
        buffer << "\r\n"
        buffer = @mobile.utf8_to_mail_encode(buffer)
        buffer << body.encoded(content_transfer_encoding)

        ascii_compatible!(buffer)
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
        @body.content_type_with_jpmobile = self.content_type

        if has_content_transfer_encoding? and
            ["base64", "quoted-printable"].include?(self.content_transfer_encoding) and
            ["text"].include?(@mobile_main_type)
          @body.decode_transfer_encoding
        end

        if @body.multipart?
          @body.parts.each do |p|
            p.charset = @mobile.mail_charset(p.charset)
            p.mobile  = @mobile
          end
        end
      end
    end

    alias_method :encoded_without_jpmobile, :encoded
    alias_method :encoded, :encoded_with_jpmobile

    alias_method :parse_message_without_jpmobile, :parse_message
    alias_method :parse_message, :parse_message_with_jpmobile

    alias_method :process_body_raw_without_jpmobile, :process_body_raw
    alias_method :process_body_raw, :process_body_raw_with_jpmobile

# -- docomo
# multipart/mixed
#   |- multipart/related
#   |    |- multipart/alternative
#   |    |    |- text/plain
#   |    |    |- text/html
#   |    |- image/xxxx (インライン画像)
#   |- image/xxxx (添付画像)

# -- au
# multipart/mixed
#   |- multipart/alternative
#   |    |- text/plain
#   |    |- text/html
#   |- image/xxxx (インライン画像)
#   |- image/xxxx (添付画像)

# -- normal
# multipart/mixed
#   |- multipart/alternative
#   |    |- text/plain
#   |    |- text/html
#   |    |- image/xxxx (インライン画像)
#   |- image/xxxx (添付画像)

    def rearrange!
      if @mobile and @mobile.decoratable?
        @mobile.decorated = true
        text_body_part = find_part_by_content_type("text/plain").first
        html_body_part = find_part_by_content_type("text/html").first
        html_body_part.transport_encoding = 'quoted-printable' if html_body_part
        inline_images  = []
        attached_files = []
        attachments.each do |p|
          if p.content_type.match(/^image\//)  and p.content_disposition.match(/^inline/)
            if p.header['Content-Type'].parameters['filename']
              p.header['Content-Type'].parameters['name'] = p.header['Content-Type'].parameters['filename'].to_s
            end
            inline_images << p
          elsif p.content_disposition
            attached_files << p
          end
        end

        alternative_part = Mail::Part.new{content_type 'multipart/alternative'}
        alternative_part.add_part(text_body_part) if text_body_part
        alternative_part.add_part(html_body_part) if html_body_part

        if @mobile.require_related_part?
          related_part = Mail::Part.new{content_type 'multipart/related'}
          related_part.add_part(alternative_part)
          inline_images.each do |inline_image|
            related_part.add_part(inline_image)
          end
          inline_images.clear
        else
          related_part = alternative_part
        end

        unless self.header['Content-Type'].sub_type == 'mixed'
          self.header['Content-Type'] = self.content_type.gsub(/#{self.header['Content-Type'].sub_type}/, 'mixed')
        end
        self.parts.clear
        self.body = nil

        self.add_part(related_part)
        inline_images.each do |inline_image|
          self.add_part(inline_image)
        end
        attached_files.each do |attached_file|
          self.add_part(attached_file)
        end
      end
    end

    def find_part_by_content_type(content_type)
      finded_parts = []

      self.parts.each do |part|
        if part.multipart?
          finded_parts << part.find_part_by_content_type(content_type)
        elsif part.content_type.match(/^#{content_type}/)
          finded_parts << part
        end
      end

      finded_parts.flatten
    end

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
          subject_value = Encodings.value_decode(self.header[:subject].value)
          subject_converting_encoding = Jpmobile::Util.detect_encoding(subject_value)
          v = @mobile.to_mail_internal(subject_value, subject_converting_encoding)
          if @charset == subject_charset and @mobile.mail_charset != @charset
            self.header[:subject].value = Jpmobile::Util.force_encode(v, @charset, Jpmobile::Util::UTF8)
          else
            self.header[:subject].value = Jpmobile::Util.force_encode(v, @mobile.mail_charset(@charset), Jpmobile::Util::UTF8)
          end
        end
      end

      if @body_part_jpmobile and @mobile and !@charset.blank?
        if ["base64", "quoted-printable"].include?(self.content_transfer_encoding) and
            self.content_type.match(/text/)
          @body_part_jpmobile = Jpmobile::Util.decode(@body_part_jpmobile, self.content_transfer_encoding, @charset)
          self.content_transfer_encoding = @mobile.class::MAIL_CONTENT_TRANSFER_ENCODING
        end
        @body_part_jpmobile = @mobile.decode_transfer_encoding(@body_part_jpmobile, @charset)
      end
    end

    def ascii_compatible!(str)
      Jpmobile::Util.ascii_compatible!(str)
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

    private
    def ascii_compatible!(str)
      str
    end
  end

  class Body
    attr_accessor :mobile, :content_type_with_jpmobile

    # convert encoding
    def encoded_with_jpmobile(transfer_encoding = '8bit')
      if @mobile and !multipart?
        if @mobile.to_mail_body_encoded?(@raw_source)
          @raw_source
        elsif Jpmobile::Util.ascii_8bit?(@raw_source)
          _raw_source = if transfer_encoding == encoding
                          @raw_source
                        else
                          enc = Mail::Encodings::get_encoding(get_best_encoding(transfer_encoding))
                          enc.encode(@raw_source)
                        end
          Jpmobile::Util.force_encode(_raw_source, nil, @charset)
        else
          case transfer_encoding
          when /quoted-printable/
            # [str].pack("M").gsub(/\n/, "\r\n")
            Jpmobile::Util.force_encode([@mobile.to_mail_body(Jpmobile::Util.force_encode(@raw_source, @charset, Jpmobile::Util::UTF8))].pack("M").gsub(/\n/, "\r\n"), Jpmobile::Util::BINARY, @charset)
            # @mobile.to_mail_body(Jpmobile::Util.force_encode(@raw_source, @charset, Jpmobile::Util::UTF8))
          else
            @mobile.to_mail_body(Jpmobile::Util.force_encode(@raw_source, @charset, Jpmobile::Util::UTF8))
          end
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

      if ["base64", "quoted-printable"].include?(self.encoding) and
          /text/.match(self.content_type_with_jpmobile)
        self.decode_transfer_encoding
      end

      if self.multipart? and @mobile
        self.parts.each do |part|
          part.charset      = @mobile.mail_charset(part.charset)
          part.mobile       = @mobile
          part.body.charset = part.charset
          part.body.mobile  = @mobile
        end
      end
    end

    def decode_transfer_encoding
      _raw_source = Jpmobile::Util.decode(@raw_source, self.encoding, @charset)
      @raw_source = @mobile.decode_transfer_encoding(_raw_source, @charset)
      self.encoding = 'text'
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
        crlf_boundary_without_jpmobile
      end
    end

    def end_boundary_with_jpmobile
      if @mobile
        Jpmobile::Util.encode(end_boundary_without_jpmobile, @charset)
      else
        end_boundary_without_jpmobile
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

  class OptionalField
    def charset
      @charset =~ /iso-2022-jp/i ? 'UTF-8' : @charset
    end
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
        self.charset = @mobile.mail_charset
        self.value   = @jpmobile_raw_text
        self.parse
      end
    end

    def encoded_with_jpmobile
      if @mobile
        self.charset = @mobile.mail_charset
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
        self.charset = @mobile.mail_charset
        self.value   = @jpmobile_raw_text
        self.parse
      end
    end

    def encoded_with_jpmobile
      if @mobile
        self.charset = @mobile.mail_charset
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

  class ContentTypeElement # :nodoc:
    def initialize_with_jpmobile(string)
      if m = string.match(/\A(.*?)(name|filename)=("|')(.+)("|')(.*?)\z/) and
          m[4].each_byte.detect { |b| (b == 0 || b > 127)}
        name = [m[4]].pack('m').strip
        string = "#{m[1]}#{m[2]}=#{m[3]}#{name}#{m[5]}#{m[6]}"
      end

      initialize_without_jpmobile(string)
    end
    alias_method :initialize_without_jpmobile, :initialize
    alias_method :initialize, :initialize_with_jpmobile
  end

  class ContentDispositionElement # :nodoc:
    def initialize_with_jpmobile(string)
      if m = string.match(/\A(.*?)(name|filename)=("|')(.+)("|')(.*?)\z/) and
          m[4].each_byte.detect { |b| (b == 0 || b > 127)}
        name = [m[4]].pack('m').strip
        string = "#{m[1]}#{m[2]}=#{m[3]}#{name}#{m[5]}#{m[6]}"
      end

      initialize_without_jpmobile(string)
    end
    alias_method :initialize_without_jpmobile, :initialize
    alias_method :initialize, :initialize_with_jpmobile
  end

  class ContentLocationElement # :nodoc:
    def initialize_with_jpmobile(string)
      if m = string.match(/\A(.*?)(name|filename)=("|')(.+)("|')(.*?)\z/) and
          m[4].each_byte.detect { |b| (b == 0 || b > 127)}
        name = [m[4]].pack('m').strip
        string = "#{m[1]}#{m[2]}=#{m[3]}#{name}#{m[5]}#{m[6]}"
      end

      initialize_without_jpmobile(string)
    end
    alias_method :initialize_without_jpmobile, :initialize
    alias_method :initialize, :initialize_with_jpmobile
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

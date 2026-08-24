require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))
require 'mail'
require 'jpmobile/mail'

describe 'decorated mails' do
  include Jpmobile::Util

  before(:each) do
    @mail           = Mail.new
    @mail.subject   = '万葉'
    @mail.text_part = Mail::Part.new do
      body 'ほげ'
    end
    @mail.from      = 'ちはやふる <info@jpmobile-rails.org>'
    @mail.to        = 'むすめふさほせ <info+to@jpmobile-rails.org>'

    @photo = File.read(File.join(__dir__, 'email-fixtures/photo.jpg'))
    @mail.attachments.inline['photo.jpg'] = @photo
    @inline_url = @mail.attachments['photo.jpg'].url
  end

  it 'leaves a non-decoratable mail structure unchanged' do
    @mail.mobile = Jpmobile::Mobile::AbstractMobile.new(nil, nil)
    original_parts = @mail.parts.dup

    @mail.rearrange!

    expect(@mail.parts).to eq(original_parts)
  end

  it 'does not add a charset to a carrier multipart container' do
    @mail.content_type = 'multipart/mixed'
    @mail.mobile = Jpmobile::Mobile::Au.new(nil, nil)

    @mail.add_charset

    expect(@mail.header['Content-Type'].parameters['charset']).to be_nil
  end

  it 'builds a decorated mail with only a text body' do
    @mail.mobile = Jpmobile::Mobile::Au.new(nil, nil)

    @mail.rearrange!

    expect(@mail.find_part_by_content_type('text/plain').size).to eq(1)
    expect(@mail.find_part_by_content_type('text/html')).to be_empty
    expect(@mail.attachments.map(&:filename)).to include('photo.jpg')
  end

  it 'builds a decorated mail with only an html body' do
    mail = Mail.new
    mail.html_part = Mail::Part.new do
      content_type 'text/html; charset=ISO-2022-JP'
      body '<p>本文</p>'
    end
    mail.mobile = Jpmobile::Mobile::Au.new(nil, nil)

    mail.rearrange!

    expect(mail.find_part_by_content_type('text/plain')).to be_empty
    expect(mail.find_part_by_content_type('text/html').size).to eq(1)
  end

  it 'keeps regular and non-image inline attachments outside the alternative body' do
    @mail.attachments['document.txt'] = 'document'
    @mail.attachments.inline['notes.txt'] = 'notes'
    @mail.mobile = Jpmobile::Mobile::Au.new(nil, nil)

    @mail.rearrange!

    expect(@mail.attachments.map(&:filename)).to contain_exactly('photo.jpg', 'document.txt', 'notes.txt')
  end

  describe 'docomo' do
    before(:each) do
      inline_url = @inline_url
      @mobile = Jpmobile::Mobile::Docomo.new(nil, nil)
      charset = @mobile.mail_charset
      @mail.html_part = Mail::Part.new do
        body '<img src="' + inline_url + '" />'
        content_type "text/html; charset=#{charset}"
      end
      @mail.mobile = @mobile
    end

    it "top level content-type should be 'multipart/mixed'" do
      @mail.rearrange!
      expect(@mail.content_type).to match('multipart/mixed')
    end
  end

  describe 'au' do
    before(:each) do
      inline_url = @inline_url
      @mobile = Jpmobile::Mobile::Au.new(nil, nil)
      charset = @mobile.mail_charset
      @mail.html_part = Mail::Part.new do
        body '<img src="' + inline_url + '" />'
        content_type "text/html; charset=#{charset}"
      end
      @mail.mobile = @mobile
    end

    it "top level content-type should be 'multipart/mixed'" do
      @mail.rearrange!
      expect(@mail.content_type).to match('multipart/mixed')
    end
  end

  describe 'softbank' do
    before(:each) do
      inline_url = @inline_url
      @mobile = Jpmobile::Mobile::Softbank.new(nil, nil)
      charset = @mobile.mail_charset
      @mail.html_part = Mail::Part.new do
        body '<img src="' + inline_url + '" />'
        content_type "text/html; charset=#{charset}"
      end
      @mail.mobile = @mobile
    end

    it "top level content-type should be 'multipart/mixed'" do
      @mail.rearrange!
      expect(@mail.content_type).to match('multipart/mixed')
    end
  end
end

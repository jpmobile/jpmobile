# -*- coding: utf-8 -*-
require 'nokogiri'
require 'scanf'
require 'pp'

xml = Nokogiri::XML(open(File.join(File.dirname(__FILE__), 'emoji4unicode.xml')).read)

google_emojis  = []
unicode_emojis = []

xml.xpath('//e').each do |emoji|
  google   = emoji.attributes['google'].value   rescue nil
  docomo   = emoji.attributes['docomo'].value   rescue '3013'
  unicode  = emoji.attributes['unicode'].value  rescue nil
  softbank = emoji.attributes['softbank'].value rescue '3013'

  google = nil if google and google.match(/[^0-9a-fA-F\+]/)
  if docomo.match(/\+/)
    docomo = '"' + docomo.split('+').map{|e| '&#x%s;' % e.gsub(/[^0-9a-fA-F\+]/, '')}.join('') + '"'
  else
    docomo = '0x%s' % docomo.gsub(/[^0-9a-fA-F]/, '')
  end

  if unicode
    if unicode.match(/\+/)
      unicodes = unicode.split(/\+/).delete_if{|e| e.strip == ''}
      if unicodes.size == 1
        unicode = '0x%s' % unicodes.first
      else
        unicode = '[' + unicodes.map{|e| '0x%s' % e.gsub(/[^0-9a-fA-F\+]/, '')}.join(', ') + ']'
      end
    else
      unicode = '0x%s' % unicode
    end
  end
  if softbank.match(/\+/)
    softbank = '"' + softbank.split('+').delete_if{|e| e.strip == ''}.map{|s| '&#x%X;' % (s.gsub(/[^0-9a-fA-F\+]/, '').scanf("%x").first + 0x1000)}.join(',') + '"'
  else
    if softbank.match(/3013/)
      softbank = '0x%s' % softbank
    else
      softbank = '0x%X' % (softbank.gsub(/[^0-9a-fA-F]/, '').scanf('%x').first + 0x1000)
    end
  end

  if google
    # Google 絵文字は docomo に寄せる
    google_emojis  << [google,  docomo]
  end

  if unicode
    # Unicode 絵文字は SoftBank に寄せる
    unicode_emojis << [unicode, softbank]
  end
end

google_emoji_rb  = open(File.join(File.dirname(__FILE__), '/../lib/jpmobile/emoticon/google.rb'), 'w') do |f|
  f.puts 'Jpmobile::Emoticon::GOOGLE_TO_DOCOMO_UNICODE = {'
  google_emojis.each do |google, docomo|
    f.puts "  0x%s => %s," % [google, docomo]
  end
  f.puts '}'
end

unicode_emoji_rb = open(File.join(File.dirname(__FILE__), '/../lib/jpmobile/emoticon/unicode.rb'), 'w') do |f|
  f.puts 'Jpmobile::Emoticon::IPHONE_UNICODE_TO_SOFTBANK_UNICODE = {'
  unicode_emojis.each do |unicode, softbank|
    f.puts "  %s => %s," % [unicode, softbank]
  end
  f.puts '}'
end

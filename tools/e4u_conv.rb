# -*- coding: utf-8 -*-
require 'nokogiri'
require 'scanf'
require 'pp'

xml = Nokogiri::XML(open(File.join(File.dirname(__FILE__), 'emoji4unicode.xml')).read)

google_docomo    = []
google_kddi      = []
google_softbank  = []
unicode_docomo   = []
unicode_kddi     = []
unicode_softbank = []

xml.xpath('//e').each do |emoji|
  # keycode
  google   = emoji.attributes['google'].value   rescue nil
  unicode  = emoji.attributes['unicode'].value  rescue nil

  # carrier code
  docomo   = emoji.attributes['docomo'].value   rescue '3013'
  softbank = emoji.attributes['softbank'].value rescue '3013'
  kddi     = emoji.attributes['kddi'].value     rescue '3013'

  # fix google key
  google = nil if google and google.match(/[^0-9a-fA-F\+]/)
  # fix unicode key
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

  # fix docomo code
  if docomo.match(/\+/)
    docomo = '"' + docomo.split('+').map{|e| '&#x%s;' % e.gsub(/[^0-9a-fA-F\+]/, '')}.join('') + '"'
  else
    docomo = '0x%s' % docomo.gsub(/[^0-9a-fA-F]/, '')
  end
  # fix softbank code
  if softbank.match(/\+/)
    softbank = '"' + softbank.split('+').delete_if{|e| e.strip == ''}.map{|s| '&#x%X;' % (s.gsub(/[^0-9a-fA-F\+]/, '').scanf("%x").first + 0x1000)}.join('') + '"'
  else
    if softbank.match(/3013/)
      softbank = '0x%s' % softbank
    else
      softbank = '0x%X' % (softbank.gsub(/[^0-9a-fA-F]/, '').scanf('%x').first + 0x1000)
    end
  end
  # fix kddi code
  if kddi.match(/\+/)
    kddi = '"' + kddi.split('+').map{|e| '&#x%s;' % e.gsub(/[^0-9a-fA-F\+]/, '')}.join('') + '"'
  else
    kddi = '0x%s' % kddi.gsub(/[^0-9a-fA-F]/, '')
  end

  if google
    google_docomo   << [google, docomo]
    google_kddi     << [google, kddi]
    google_softbank << [google, softbank]
  end

  if unicode
    # Unicode 絵文字は SoftBank に寄せる
    unicode_docomo   << [unicode, docomo]
    unicode_kddi     << [unicode, kddi]
    unicode_softbank << [unicode, softbank]
  end
end

google_emoji_rb  = open(File.join(File.dirname(__FILE__), '/../lib/jpmobile/emoticon/google.rb'), 'w') do |f|
  # docomo
  f.puts 'Jpmobile::Emoticon::GOOGLE_TO_DOCOMO_UNICODE = {'
  google_docomo.each do |google, docomo|
    f.puts "  0x%s => %s," % [google, docomo]
  end
  f.puts '}'

  # kddi
  f.puts 'Jpmobile::Emoticon::GOOGLE_TO_AU_UNICODE = {'
  google_kddi.each do |google, kddi|
    f.puts "  0x%s => %s," % [google, kddi]
  end
  f.puts '}'

  # softbank
  f.puts 'Jpmobile::Emoticon::GOOGLE_TO_SOFTBANK_UNICODE = {'
  google_softbank.each do |google, softbank|
    f.puts "  0x%s => %s," % [google, softbank]
  end
  f.puts '}'
end

unicode_emoji_rb = open(File.join(File.dirname(__FILE__), '/../lib/jpmobile/emoticon/unicode.rb'), 'w') do |f|
  # docomo
  f.puts 'Jpmobile::Emoticon::UNICODE_TO_DOCOMO_UNICODE = {'
  unicode_docomo.each do |unicode, docomo|
    f.puts "  %s => %s," % [unicode, docomo]
  end
  f.puts '}'

  # docomo
  f.puts 'Jpmobile::Emoticon::UNICODE_TO_AU_UNICODE = {'
  unicode_kddi.each do |unicode, kddi|
    f.puts "  %s => %s," % [unicode, kddi]
  end
  f.puts '}'

  # softbank
  f.puts 'Jpmobile::Emoticon::UNICODE_TO_SOFTBANK_UNICODE = {'
  unicode_softbank.each do |unicode, softbank|
    f.puts "  %s => %s," % [unicode, softbank]
  end
  f.puts '}'
end

# -*- coding: utf-8 -*-
class DecoratedMailer < Jpmobile::Mailer::Base
  default :from => "info@jp.mobile"
  default :to   => "info@jp.mobile"

  def deco_mail(to_mail)
    attachments.inline['photo.jpg'] = open(File.join(Rails.root, 'spec/fixtures/mobile_mailer/photo.jpg')).read

    mail(:to => to_mail, :subject => '題名', :decorated => true)
  end
end

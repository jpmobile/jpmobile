# -*- coding: utf-8 -*-
class NormalMailer < ActionMailer::Base
  default :from => "info@jp.mobile"

  def msg(to_mail, subject_text, text)
    @text = text
    mail(:to => to_mail, :subject => subject_text)
  end
end

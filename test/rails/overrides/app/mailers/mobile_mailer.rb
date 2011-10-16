# -*- coding: utf-8 -*-
class MobileMailer < Jpmobile::Mailer::Base
  default :from => "info@jp.mobile"
  default :to   => "info@jp.mobile"

  def view_selection(to_mail, subject_text, text)
    @text = text
    mail(:to => to_mail, :subject => subject_text)
  end

  def receive(email)
    email
  end

  def multi_message(to_mail, subject_text, text, html)
    @html = html
    @text = text
    mail(:to => to_mail, :subject => subject_text)
  end

  def default_to_mail(subject_text, text)
    @text = text
    mail(:subject => subject_text)
  end
end

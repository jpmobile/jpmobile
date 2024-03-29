class DecoratedMailer < Jpmobile::Mailer::Base
  default from: 'info@jp.mobile'
  default to: 'info@jp.mobile'

  def deco_mail(to_mail)
    attachments.inline['photo.jpg'] = File.read(File.join(Rails.root, 'spec/fixtures/files/mobile_mailer/photo.jpg'))

    mail(to: to_mail, subject: '題名', decorated: true)
  end
end

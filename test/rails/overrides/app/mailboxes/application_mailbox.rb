class ApplicationMailbox < ActionMailbox::Base
  routing /.*/ => :mobile_mailer
end

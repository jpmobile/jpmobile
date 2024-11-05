require 'rails_helper'

Dir[File.join(__dir__, 'system/support/**/*.rb')].each {|file| require file }

def extract_response_header(page, header)
  page.response_headers[header] || page.response_headers[header.downcase]
end

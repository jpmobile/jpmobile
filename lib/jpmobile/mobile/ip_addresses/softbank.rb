module Jpmobile
  module Mobile
    module IpAddresses
      class Softbank < AbstractIpAddresses
        class << self
          def ip_address_list
            @@ip_address_list ||= [
              "123.108.237.0/27",
              "202.253.96.224/27",
              "210.146.7.192/26",
              "210.175.1.128/25"
            ].map {|ip| IPAddr.new(ip) }
          end
        end
      end
      class Vodafone < Softbank
      end
    end
  end
end

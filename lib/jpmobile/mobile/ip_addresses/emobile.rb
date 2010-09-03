module Jpmobile
  module Mobile
    module IpAddresses
      class Emobile < AbstractIpAddresses
        class << self
          def ip_address_list
            @@ip_address_list ||= [
              "117.55.1.224/27"
            ].map {|ip| IPAddr.new(ip) }
          end
        end
      end
    end
  end
end

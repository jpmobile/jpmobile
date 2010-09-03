module Jpmobile
  module Mobile
    module IpAddresses
      class Docomo < AbstractIpAddresses
        class << self
          def ip_address_list
            @@ip_address_list ||= [
              "210.153.84.0/24",
              "210.136.161.0/24",
              "210.153.86.0/24",
              "124.146.174.0/24",
              "124.146.175.0/24",
              "202.229.176.0/24",
              "202.229.177.0/24",
              "202.229.178.0/24"
            ].map {|ip| IPAddr.new(ip)}
          end
        end
      end
    end
  end
end

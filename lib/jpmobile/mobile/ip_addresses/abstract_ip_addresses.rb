module Jpmobile
  module Mobile
    module IpAddresses
      class AbstractIpAddresses
        def valid_ip?(remote_ip_str)
          begin
            remote_ip = IPAddr.new(remote_ip_str)
          rescue
            return false
          end

          self.class.ip_address_list.any? {|ip| ip.include?(remote_ip)}
        end

        class << self
          def ip_address_list
            []
          end
        end
      end
    end
  end
end

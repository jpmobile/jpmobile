module Rack
  module Session
    class Dalli
      def destroy_session_with_jpmobile(env, session_id, options)
        destroy_session_without_jpmobile(env, session_id, options)

        session_id || generate_sid
      end

      alias_method_chain :destroy_session, :jpmobile
    end
  end
end

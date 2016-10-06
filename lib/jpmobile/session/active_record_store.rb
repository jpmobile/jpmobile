module Jpmobile
  module ActiveRecordStoreRegenerateSessionId
    def destroy_session(env, session_id, options)
      super(env, session_id, options)

      session_id || Jpmobile::SessionID.generate_sid
    end
  end
end

ActionDispatch::Session::ActiveRecordStore.send :prepend, Jpmobile::ActiveRecordStoreRegenerateSessionId

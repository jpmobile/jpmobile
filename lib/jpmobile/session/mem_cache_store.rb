module Jpmobile
  module MemCacheStoreRegenerateSessionId
    def destroy_session(env, session_id, options)
      super(env, session_id, options)

      session_id || generate_sid
    end
  end
end

ActionDispatch::Session::MemCacheStore.send :prepend, Jpmobile::MemCacheStoreRegenerateSessionId

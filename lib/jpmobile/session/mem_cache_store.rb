module Jpmobile
  module MemCacheStoreRegenerateSessionId
    def destroy_session(env, session_id, options)
      super

      session_id || generate_sid
    end
  end
end

ActionDispatch::Session::MemCacheStore.prepend Jpmobile::MemCacheStoreRegenerateSessionId

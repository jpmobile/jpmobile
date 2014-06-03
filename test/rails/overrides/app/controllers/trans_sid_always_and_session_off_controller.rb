class TransSidAlwaysAndSessionOffController < TransSidBaseController
  trans_sid :always
  skip_before_action :session_init
end

class TransSidAlwaysAndSessionOffController < TransSidBaseController
  trans_sid :always
  skip_before_filter :session_init
end

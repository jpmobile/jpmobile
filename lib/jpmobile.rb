
Dir[File.join(File.dirname(__FILE__), 'jpmobile/**/*.rb')].sort.each { |lib| require lib }

#:stopdoc:
# CgiRequestを拡張
ActionController::CgiRequest.class_eval { include Jpmobile::CgiRequestExpansion}
# helperを追加
ActionView::Base.class_eval { include Jpmobile::Helpers }
#:startdoc:

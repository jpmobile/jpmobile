
Dir[File.join(File.dirname(__FILE__), 'jpmobile/**/*.rb')].sort.each { |lib| require lib }

#:stopdoc:
# helperを追加
ActionView::Base.class_eval { include Jpmobile::Helpers }
#:startdoc:

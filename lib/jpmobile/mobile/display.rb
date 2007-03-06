# = 端末のディスプレイに関する情報
#  request.mobile.display
# で取得できる。
module Jpmobile
  # ディスプレイ情報
  class Display
    def initialize(physical_width=nil, physical_height=nil, browser_width=nil, browser_height=nil, color_p=nil, colors=nil) # :nodoc:
      @physical_width = physical_width
      @physical_height = physical_height
      @browser_width = browser_width
      @browser_height = browser_height
      @colors = colors
      @color_p = color_p
    end
    
    # 画面がカラーならば +true+、白黒ならば +false+ を返す。不明の場合は +nil+。
    def color?; @color_p; end
    # 画面の色数を返す。不明の場合は +nil+。
    def colors; @colors; end
    # ディスプレイの画面幅を返す。不明の場合は +nil+。
    def physical_width; @physical_width; end
    # ディスプレイの画面高さを返す。不明の場合は +nil+。
    def physical_height; @physical_height; end
    # ブラウザの画面幅を返す。不明の場合は +nil+。
    def browser_width; @browser_width; end
    # ブラウザの画面高さを返す。不明の場合は +nil+。
    def browser_height; @browser_height; end
    # 画面の幅を返す。ブラウザ画面の幅がわかる場合はそれを優先する。不明の場合は +nil+。
    def width; browser_width || physical_width; end
    # 画面の高さを返す。ブラウザ画面の高さがわかる場合はそれを優先する。不明の場合は +nil+。
    def height; browser_height || physical_height; end
  end
end

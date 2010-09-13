# -*- coding: utf-8 -*-
# = 端末のディスプレイに関する情報
#  request.mobile.display
# で取得できる。
module Jpmobile
  module Mobile
    # ディスプレイ情報
    class Display
      def initialize(carrier, env)
        case carrier
        when Docomo
          display_info = Jpmobile::Mobile::Docomo::DISPLAY_INFO[carrier.model_name] || {}
          @browser_width = display_info[:browser_width]
          @browser_height = display_info[:browser_height]
          @color_p = display_info[:color_p]
          @colors = display_info[:colors]
        when Au
          if r = env['HTTP_X_UP_DEVCAP_SCREENPIXELS']
            @physical_width, @physical_height = r.split(/,/,2).map {|x| x.to_i}
          end
          if r = env['HTTP_X_UP_DEVCAP_ISCOLOR']
            @color_p = (r == '1')
          end
          if r = env['HTTP_X_UP_DEVCAP_SCREENDEPTH']
            a = r.split(/,/)
            @colors = 2 ** a[0].to_i
          end
        when Softbank
          if r = env['HTTP_X_JPHONE_DISPLAY']
            @physical_width, @physical_height = r.split(/\*/,2).map {|x| x.to_i}
          end
          if r = env['HTTP_X_JPHONE_COLOR']
            case r
            when /^C/
              @color_p = true
            when /^G/
              @color_p = false
            end
            if r =~ /^.(\d+)$/
              @colors = $1.to_i
            end
          end
        end
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
end

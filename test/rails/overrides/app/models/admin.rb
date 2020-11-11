class User < ActiveRecord::Base
  protected
    def hoge
    end

    private
    def foo
    end

    def long
      time = Time.zone.now.to_i

      if time % 2 == 0
        if time % 3 == 0
          if time % 5 == 0
            if time % 7 == 0
              puts 'OK'
            else
              puts 'HAT'
            end
          else
            puts 'ELSE'
          end
        else
          puts 'BUT'
        end
      else
        puts 'NOT'
      end
    end
end

# =測地系変換モジュール
#
# 参考文献:
# 飛田幹男, 世界測地系と座標変換--21世紀の測量士・位置情報ユーザ・プログラマーのために,
# 日本測量協会, 2002.

module DatumConv
  GRS80  = [    6378137, 298.257222101]
  Bessel = [6377397.155, 299.152813]
  Tokyo97toITRF94 = [-146.414, 507.337, 680.507]
  ITRF94toTokyo97 = [ 146.414,-507.337,-680.507]
  Deg2Rad = Math::PI/180

  # 緯度(度),経度(度),高度(m)を三次元直交座標(m)に変換する。
  def self.blh2xyz(b_deg,l_deg,he,datum)
    a = datum[0].to_f
    f = 1.0/datum[1]
    b = b_deg * Deg2Rad
    l = l_deg * Deg2Rad

    e2 = f * (2 - f)
    n = a / Math.sqrt(1 - e2 * Math.sin(b)**2 )

    x = (n+he)*Math.cos(b)*Math.cos(l)
    y = (n+he)*Math.cos(b)*Math.sin(l)
    z = (n*(1-e2)+he)*Math.sin(b)
    return x,y,z
  end

  # 三次元直交座標(m)を緯度(度),経度(度),高度(m)に変換する。
  def self.xyz2blh(x,y,z,datum)
    a = datum[0].to_f
    f = 1.0/datum[1]
    e2 = f * (2 - f)
    l = Math.atan2(y,x)

    p = Math.sqrt(x**2+y**2)
    r = Math.sqrt(p**2+z**2)
    u = Math.atan2(z*((1-f)+e2*a/r),p)
    b = Math.atan2(z*(1-f)+e2*a*Math.sin(u)**3,(1-f)*(p-e2*a*Math.cos(u)**3))

    he = p*Math.cos(b) + z*Math.sin(b) - a*Math.sqrt(1-e2*Math.sin(b)**2)

    b_deg = b / Deg2Rad
    l_deg = l / Deg2Rad
    return b_deg,l_deg,he
  end

  # 三次元直交座標でシフトする。
  def self.xyz2xyz(x,y,z,d)
    return x+d[0],y+d[1],z+d[2]
  end

  # 日本測地系から世界測地系に変換する。
  def self.tky2jgd(b,l,he=0)
    x,y,z = blh2xyz(b,l,he,Bessel)
    x,y,z = xyz2xyz(x,y,z,Tokyo97toITRF94)
    b,l,he = xyz2blh(x,y,z,GRS80)
    return b,l,he
  end

  # 世界測地系から日本測地系に変換する。
  def self.jgd2tky(b,l,he=0)
    x,y,z = blh2xyz(b,l,he,GRS80)
    x,y,z = xyz2xyz(x,y,z,ITRF94toTokyo97)
    b,l,he = xyz2blh(x,y,z,Bessel)
    return b,l,he
  end
end

#DatumConv.tky2jgd(b,l)
#DatumConv.jgd2tky(b,l)

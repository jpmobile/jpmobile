require 'scanf'

def to_ranges(array)
  sorted = array.sort.uniq
  results = []
  start = nil
  for i in 0...sorted.size
    start ||= sorted[i]
    if i == sorted.size-1 || sorted[i+1] - sorted[i] > 1
      if start == sorted[i]
        results << start
      else
        results << (start..sorted[i])
      end
      start = nil
    end
  end
  results
end

def ranges_to_regexp(array)
  r = ""
  array.each do |x|
    if x.is_a? Range
      r << "\\x%02x-\\x%02x" % [x.first, x.last]
    else
      r << "\\x%02x" % x
    end
  end
  r
end

h = Hash.new {|h,k| h[k]=[]}

ARGF.each do |l|
  l.chomp!
  sjis_bin = [[l].pack("H4")].first
  a = l.scanf("%02X%02X")
  h[a.first] << a.last
end

re = []
h.sort.each do |k,v|
  re << "\\x%02x"%k + '['+ranges_to_regexp(to_ranges(v))+']'
  p ["\\x%02x"%k, to_ranges(v), ranges_to_regexp(to_ranges(v))]
end
puts re.join('|')

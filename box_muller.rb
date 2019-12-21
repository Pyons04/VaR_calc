require './libs'

array = []
generate = Random.new
100000.times do 
  array << BoxMuller::randum(0,1)
end

p array.average
p array.stdv

p array.select{|x| (0 <= x) }.size / array.size.to_f
p array.select{|x| (0.0 <= x) && (x <= 1.0) }.size / array.size.to_f
p array.select{|x| (0.0 <= x) && (x <= 2.0) }.size / array.size.to_f
p array.select{|x| (0.0 <= x) && (x <= 3.0) }.size / array.size.to_f


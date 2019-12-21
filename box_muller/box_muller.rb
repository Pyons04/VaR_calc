require '../libs'
require 'csv'

array = []
generate = Random.new
50000.times do 
  array << BoxMuller::randum(0,1)
end

ave =  ["Mean of Samples", array.average]
stdv = ["Stdv of Samples", array.stdv]

nd_table_half = ["Samles greater than 0", array.select{|x| (0 <= x) }.size / array.size.to_f]
nd_table_x = [["Standard Normal Distribution Table",""]]

z = 0.0
while (z <= 5.0) do 
  nd_table_x << [z.round(1),(array.select{|x| (0.0 <= x) && (x <= z.round(1)) }.size / array.size.to_f)]
  z += 0.1
end

nd_table_x.unshift(nd_table_half)
nd_table_x.unshift(stdv)
nd_table_x.unshift(ave)
nd_table_x.unshift(["","Box Muller's Method"])

CSV.open('box_mullers_method_result.csv','w+') do |content|
  nd_table_x.each do |row|
    content << row 
  end
end






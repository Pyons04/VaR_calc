require '../libs'
require 'csv'

NormSDistTableExample = [
  0,
  0.0398,
  0.0793,
  0.1179,
  0.1554,
  0.1915,
  0.2257,
  0.258,
  0.2881,
  0.3159,
  0.3413,
  0.3643,
  0.3849,
  0.4032,
  0.4192,
  0.4332,
  0.4452,
  0.4554,
  0.4641,
  0.4713,
  0.4772,
  0.4821,
  0.4861,
  0.4893,
  0.4918,
  0.4938,
  0.4953,
  0.4965,
  0.4974,
  0.4981,
  0.4987,
  0.499,
  0.4993,
  0.4995,
  0.4997,
  0.4998,
  0.4998,
  0.4999,
  0.49993,
  0.49995,
  0.49997,
  0.49998,
  0.49999,
  0.49999,
  0.49999,
  0.49997,
  0.49998,
  0.49999,
  0.49999,
  0.499995,
  0.499997
].freeze

def generate_csv 
  csv_export = []
  csv_export << ["Method","Expected","Box Muller","Excel Randum"]
  csv_export << ["Mean of Samples"]
  csv_export << ["Stdv of Samples"]
  csv_export << ["Rate of Samples greater than 0"]
  csv_export << ["Sample Size"]
  csv_export << ["","","",""]
  csv_export << ["Standard Normal Distribution Table","","",""]
  z = 0.0
  while (z <= 5.0) do 
    csv_export << [z.round(1)]
    z += 0.1
  end
  return csv_export
end

def analitics(array,csv_export)
  csv_export[1] << array.average
  csv_export[2] << array.stdv
  csv_export[3] << array.select{|x| (0 <= x) }.size / array.size.to_f
  csv_export[4] << array.size

  z = 0.0
  t = 0
  while (z <= 5.0) do 
    csv_export[7 + t] << array.select{|x| (0.0 <= x) && (x <= z.round(1)) }.size / array.size.to_f
    z += 0.1
    t += 1
  end
  return csv_export
end

def box_muller
  array = []
  50000.times do 
    array << BoxMuller::randum(0,1)
  end
  return array
end

def expections(csv_export)
  csv_export[1] << "0"
  csv_export[2] << "1"
  csv_export[3] << "0.5"
  csv_export[4] << ""

  NormSDistTableExample.each_with_index do |data, index|
    csv_export[index + 7] << data
  end
  return csv_export
end

def excel_randum
  CSV.read("./excelRandum.csv").flatten.map{|x| x.to_f}
end

csv = expections(generate_csv)
csv = analitics(box_muller,csv)
csv = analitics(excel_randum,csv)

CSV.open('box_mullers_method_result.csv','w+') do |content|
  csv.each do |row|
    content << row 
  end
end






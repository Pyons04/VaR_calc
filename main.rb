 require './libs'
 require './libs_with_rubystats'
 include WithRubyStats

priceData = CSV.read("./data.csv").map{|x| x[1] }
historical = PriceDate.new(priceData)
csv_export = [["Simuration Executed Date", Time.now.to_s],["","Simuration Result"]]

csv_export << ['HistoricalData Average', historical.returns.average]
csv_export << ['HistoricalData Stdv', historical.returns.stdv]
csv_export << []

simurated = SimuratedReturn.new(
  ave: historical.returns.average,
  stdv: historical.returns.stdv,
  times: 50000
)

csv_export << ['Simulated Return Average', simurated.average]
csv_export << ['Simulated Return Stdv',simurated.stdv.to_s]
csv_export << []

csv_export << ['Simulated Security Price Average', simurated.sampleIndex(historical.last).average]
csv_export << ['Simulated Security Price Stdv ', simurated.sampleIndex(historical.last).stdv]
csv_export << []

callOptionPrices = CallOption.new(
  sampleIndex: simurated.sampleIndex(historical.last),
  latestPrice: historical.last
)

csv_export << ['Latest Call Option Price', BlackScholes::equation(vals: callOptionPrices.vals, samplePrice: historical.last)]
csv_export << []

csv_export << ['Simulated Call Option Price Average', callOptionPrices.average]
csv_export << ['Simulated Call Option Price Stdv', callOptionPrices.stdv]
csv_export << []

csv_export << ['Simulated Call Option Return Average', callOptionPrices.returns.average]
csv_export << ['Simulated Call Option Return Stdv', callOptionPrices.returns.stdv]
csv_export << []

csv_export << [ '1 Day 95% VaR', ((callOptionPrices.returns.average - 1.6545 * callOptionPrices.returns.stdv) * 100).to_s + '%']
csv_export << [ '1 Day 99% VaR', ((callOptionPrices.returns.average - 2.33 * callOptionPrices.returns.stdv) * 100).to_s + '%']

CSV.open('val_simuration_result.csv','w+') do |content|
  csv_export.each do |row|
    content << row 
  end
end

puts "Done!"
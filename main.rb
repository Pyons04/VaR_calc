# require './libs'
require './libs_with_rubystats'

priceData = CSV.read("./data.csv").map{|x| x[1] }
historical = PriceDate.new(priceData)

p 'ヒストリカルデータ平均: ' +  historical.returns.average.to_s
p 'ヒストリカルデータ標準偏差: ' + historical.returns.stdv.to_s
p 'ヒストリカルデータ最新価格: ' + historical.last.to_s
puts 

simurated = SimuratedReturn.new(
  ave: historical.returns.average,
  stdv: historical.returns.stdv,
  times: 50000
)

p 'シュミレーション平均: ' + simurated.average.to_s
p 'シュミレーション標準偏差: ' + simurated.stdv.to_s
puts 

p 'サンプルインデックス価格平均: ' + simurated.sampleIndex(historical.last).average.to_s
p 'サンプルインデックス価格標準偏差: ' + simurated.sampleIndex(historical.last).stdv.to_s
puts

sampleIndex = simurated.sampleIndex(historical.last)

callOptionPrices = CallOption.new(
  sampleIndex: sampleIndex,
  latestPrice: historical.last
)
p '最新のコールオプション価格: ' + BlackScholes::equation(vals: callOptionPrices.vals, samplePrice: historical.last).to_s
puts 

p 'コールオプション平均: ' + callOptionPrices.average.to_s
p 'コールオプション標準偏差: ' + callOptionPrices.stdv.to_s
puts

p 'コールオプションリターン平均 : ' + callOptionPrices.returns.average.to_s
p 'コールオプションリターン標準偏差: ' + callOptionPrices.returns.stdv.to_s
puts

puts '1 Day 95% VaR :' + ((callOptionPrices.returns.average - 1.6545 * callOptionPrices.returns.stdv) * 100).to_s + '%'
puts '1 Day 99% VaR :' + ((callOptionPrices.returns.average - 2.33 * callOptionPrices.returns.stdv) * 100).to_s + '%'
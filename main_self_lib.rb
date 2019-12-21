
require 'csv'
require 'rubystats'
class Array
  def average 
    return (self.sum.to_f / self.length.to_f)
  end

  def variance
    diffsFromAve = []
    self.each do |element|
      diffsFromAve << (element - self.average)**2
    end
    return  diffsFromAve.sum / self.size
  end

  def stdv
    Math.sqrt(self.variance).to_f
  end
end

class PriceDate < Array
  def initialize(data)
     self.replace(data.map{|x| x.to_f})
  end

  def returns
    historicalReturn = []
    self.each_index do |i|
      break if self.size - 1 == i
      historicalReturn << (self[i+1] - self[i]) / self[i]  
    end
    return historicalReturn
  end
end

module BoxMuller
  @generate = Random.new
  def randum(ave, stdv)
    normSDist = Math.sqrt(-2.0 * Math.log(@generate.rand)) * Math.sin(2.0 * Math::PI * @generate.rand)
    return ave + (stdv * normSDist) 
  end
  module_function :randum
end

class SimuratedReturn < Array

  def initialize(ave:, stdv:, times:)
    result = []
    normsdist = NormalDistribution.new(ave, stdv)
    times.times do
    # result << BoxMuller::randum(ave,stdv)
      result << normsdist.rng
    end
    self.replace(result)
  end
  def sampleIndex(latest)
    result = []
    self.each do |returnRate|
      result << latest * (returnRate + 1)
    end
    return result
  end
end

module NormSDist
  def cdf(x)
    return (1 + Math::erf(x/Math::sqrt(2)))/2
  end
  module_function :cdf
end



module BlackScholes
  def equation(vals:, samplePrice:)
    # normsdist = NormalDistribution.new(0, 1)
    d1 = (Math.log(samplePrice / vals[:strike]) + (vals[:riskFree] + 0.5 * (vals[:volatility] ** 2) ) * vals[:maturity]) /  (vals[:volatility] * Math.sqrt(vals[:maturity]))
    d2 = d1 - vals[:volatility] * Math.sqrt(vals[:maturity])
    return (samplePrice * NormSDist::cdf(d1) - vals[:strike] * Math::E ** (-vals[:riskFree] * vals[:maturity]) * NormSDist::cdf(d2))
  end
  module_function :equation
end

class CallOption < Array
  def vals
    {
      strike: 24500,
      riskFree: 0.05,
      volatility: 0.25,
      maturity: 0.25
    }
  end
  def initialize (sampleIndex:, latestPrice:)
    @historialLatest = latestPrice
    results = []
    sampleIndex.each do |samplePrice|
      results << BlackScholes::equation(vals: vals.merge({maturity: 0.25 - (1/260r)}), samplePrice: samplePrice)
    end
    self.replace(results)
  end
  def returns
    latestCallOptionPrice = BlackScholes::equation(vals: vals, samplePrice: @historialLatest)
    result = []
    self.each do |optionPrice|
      result << ((optionPrice - latestCallOptionPrice) / latestCallOptionPrice)
    end
    return result
  end
end

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
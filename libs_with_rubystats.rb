
require 'csv'
require 'rubystats'  # Do 'gem install rubystats' before.

module WithRubyStats
  puts "rubystats used."
  class SimuratedReturn < Array
    def initialize(ave:, stdv:, times:)
      result = []
      normsdist = NormalDistribution.new(ave, stdv)
      times.times do
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

  module BlackScholes
    def equation(vals:, samplePrice:)
      normsdist = NormalDistribution.new(0, 1)
      d1 = (Math.log(samplePrice / vals[:strike]) + (vals[:riskFree] + 0.5 * (vals[:volatility] ** 2) ) * vals[:maturity]) /  (vals[:volatility] * Math.sqrt(vals[:maturity]))
      d2 = d1 - vals[:volatility] * Math.sqrt(vals[:maturity])
      return (samplePrice * normsdist.cdf(d1) - vals[:strike] * Math::E ** (-vals[:riskFree] * vals[:maturity]) * normsdist.cdf(d2))
    end
    module_function :equation
  end
end
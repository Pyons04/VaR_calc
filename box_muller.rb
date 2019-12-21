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

module BoxMuller
  @generate = Random.new
  def randum(ave, stdv)
    normSDist = Math.sqrt(-2.0 * Math.log(@generate.rand)) * Math.sin(2.0 * Math::PI * @generate.rand)
    return ((normSDist * (stdv ** 2)) + ave)
  end
  module_function :randum
end

array = []
generate = Random.new
100000.times do 
  array << BoxMuller::randum(0,1)
end

p array.select{|x| (0 <= x) }.size / array.size.to_f
p array.select{|x| (0.0 <= x) && (x <= 1.0) }.size / array.size.to_f
p array.select{|x| (0.0 <= x) && (x <= 2.0) }.size / array.size.to_f
p array.select{|x| (0.0 <= x) && (x <= 3.0) }.size / array.size.to_f
p array.average
p array.stdv

module NormSDist
  def cdf(x)
    return (1 + Math::erf(x/Math::sqrt(2)))/2
  end
  module_function :cdf
end

require 'rubystats' 
normsdist = NormalDistribution.new(0, 1)
x = 0
100.times do
  p (normsdist.cdf(x)) == (NormSDist::cdf(x))
  #p NormSDist::cdf(x)
  x += 0.1
end


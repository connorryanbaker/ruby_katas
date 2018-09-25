#https://www.codewars.com/kata/prime-number-decompositions/ruby
class Factorizer
  attr_accessor :factors
  def initialize(n)
    @n = n
    @factors = Hash.new(0)
    factorize(n)
  end

  def factorize(n)
    2.upto(n) do |e|
      if n % e == 0
        @factors[e] += 1
        return factorize(n / e)
      end
    end
  end

  def prime_array
    return [1] if @n == 1
    arr = []
    @factors.each_key do |key|
      @factors[key].times do |e|
        arr << key
      end
    end
    p arr
  end

  def unique_prime_array
    return [[1],[1]] if @n == 1
    arr = []
    arr << @factors.keys
    arr << @factors.values
    arr
  end

  def prime_products_array
    return [1] if @n == 1
    arr = []
    @factors.each_key {|key| arr << key ** @factors[key]}
    arr
  end
end

def getAllPrimeFactors(n)
  if !n.is_a?(Integer) || n <= 0
    return []
  end
  Factorizer.new(n).prime_array
end

def getUniquePrimeFactorsWithCount(n)
  if !n.is_a?(Integer) || n <= 0
    return [[],[]]
  end
  Factorizer.new(n).unique_prime_array
end

def getUniquePrimeFactorsWithProducts(n)
  if !n.is_a?(Integer) || n <= 0
    return []
  end
  Factorizer.new(n).prime_products_array
end

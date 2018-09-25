#https://www.codewars.com/kata/primes-in-numbers/ruby
class Factorizer
  attr_accessor :factors
  def initialize(n)
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

  def print_string
    str = ""
    @factors.each_key do |key|
      @factors[key] == 1 ? str += "(#{key})" : str += "(#{key}**#{@factors[key]})"
    end
    str
  end
end

def primeFactors(n)
  Factorizer.new(n).print_string
end

class Integer
  def prime?
    return false if self <= 1

    divisors = 2.upto Math.sqrt abs
    divisors.each { |divisor| if abs % divisor == 0 then return false end }
    true
  end

  def prime_factors
    return [] if abs == 1

    factor = (2..abs).find { |divisor| abs % divisor == 0 and divisor.prime? }
    [factor] + (abs/factor).prime_factors
  end

  def harmonic
    sum = 0.0r
    (1..abs).each { |number| sum += Rational(1, number) }
    sum
  end

  def digits
    digits = []
    abs.to_s.split('').each { |digit| digits << digit.to_i }
    digits
  end
end

class Array
  def frequencies
    frequencies = Hash.new(0)
    each { |key| frequencies[key] += 1 }
    frequencies
  end

  def average
    reduce { |accumulator, element| accumulator + element } / size.to_f
  end

  def drop_every(n)
    each_slice(n).map { |list| list[0, n-1] }.flatten
  end

  def combine_with(other)
    zip(other).flatten.compact
  end
end
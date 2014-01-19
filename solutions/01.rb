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
    (1..self).map(&:reciprocal).reduce(:+) if self > 0
  end

  def reciprocal
    1 / to_r
  end

  def digits
    abs.to_s.chars.map(&:to_i)
  end
end

class Array
  def frequencies
    each_with_object Hash.new(0) do |value, result|
      result[value] += 1
    end
  end

  def average
    reduce(:+) / length.to_f unless empty?
  end

  def drop_every(n)
    each_slice(n).map { |slice| slice[0, n-1] }.flatten
  end

  def combine_with(other)
    longer, shorter = self.length > other.length ? [self, other] : [other, self]

    combined = take(shorter.length).zip(other.take(shorter.length)).flatten 1
    rest = longer.drop(shorter.length)

    combined + rest
  end
end
module Asm
  module Instructions
    def mov(destination_register, source)
      @registers[destination_register] = get_value source
    end

    def inc(destination_register, value = 1)
      @registers[destination_register] += get_value value
    end

    def dec(destination_register, value = 1)
      @registers[destination_register] -= get_value value
    end

    def cmp(register, value)
      @last_comparison = @registers[register] <=> get_value value
    end

    def get_value(value)
      @registers[value] or value
    end
  end


  class Evaluator

    include Instructions
    
    def initialize
      @registers = {ax: 0, bx: 0, cx: 0, dx: 0}
      @last_comparison = 0
      @operations = []
      @labels = {}
    end
  end

  def self.perform_operations(evaluator)
    evaluator.operations_queue.each do |operation|
      if operation[0] == :'='
        evaluator.send operation[1].name+"=", get_value(operation[2])
      else
        is_cmp?(operation, evaluator)
      end
    end
  end

  private

  def self.is_cmp?(operation, evaluator)
    if operation[0] == :'<=>'
      evaluator.last_cmp = operation[1].value.send operation[0], get_value(operation[2])
    else
      operation[1].value = operation[1].value.send operation[0], get_value(operation[2])
    end
  end

  def self.get_value(value)
      value.nil? ? 1 : ((value.is_a? Integer) ? value : value.value)
  end

  def self.asm(&block)
    evaluator = Evaluator.new
    evaluator.instance_eval(&block)
    perform_operations(evaluator)

    evaluator.registers.map { |register| register.value }
  end
end
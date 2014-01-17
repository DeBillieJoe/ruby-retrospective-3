module Asm
  class Evaluator

    attr_accessor :ax, :bx, :cx, :dx, :registers, :last_cmp, :operations_queue

    operations = {
      mov: :'=',
      inc: :'+',
      dec: :'-',
      cmp: :'<=>',
      jg: :'jg',
      label: :'label'
    }

    operations.each do |operation_name, operation|
      define_method operation_name do |*arguments|
        @operations_queue << [operation, *arguments]
      end
    end

    def initialize
      @ax, @bx, @cx, @dx = Register.new("ax"),  Register.new("bx"),
                           Register.new("cx"),  Register.new("dx")
      @registers = [@ax, @bx, @cx, @dx]
      @operations_queue = []
      @labeled_operations = {}
    end

    def ax=(value)
      @ax.value = value
    end

    def bx=(value)
      @bx.value = value
    end

    def cx=(value)
      @cx.value = value
    end

    def dx=(value)
      @dx.value = value
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

  class Register
    attr_accessor :value, :name

    def initialize(name)
      @value = 0
      @name = name
    end
  end
end
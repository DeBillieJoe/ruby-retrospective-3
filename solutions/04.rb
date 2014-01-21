module Asm
  module Instructions
    def mov(destination_register, source)
      @registers[destination_register] = get_actual_value(source)
    end

    def inc(destination_register, value = 1)
      @registers[destination_register] += get_actual_value(value)
    end

    def dec(destination_register, value = 1)
      @registers[destination_register] -= get_actual_value(value)
    end

    def cmp(register, value)
      @last_comparison = (@registers[register] <=> get_actual_value(value))
    end

    def get_actual_value(value)
      @registers[value] or value
    end
  end

  module Jumps
    def jmp(where)
      @pointer = (@labels[where] or where)
    end

    jumps = {
      je:  :'==',
      jne: :'!=',
      jl:  :'<',
      jle: :'<=',
      jg:  :'>',
      jge: :'>='
    }

    jumps.each do |jump_name, comparison|
      define_method jump_name do |where|
        if @last_comparison.public_send(comparison, 0)
          return jmp(where)
        else
          @pointer = @pointer.succ
        end
      end
    end
  end

  class Evaluator
    include Instructions
    include Jumps

    class Storage
      attr_reader :labels, :operations

      def initialize(&block)
        @operations = []
        @labels = {}
        instance_eval(&block)
      end

      def method_missing(method_name, *args)
        all_operations = Instructions.instance_methods + Jumps.instance_methods
        if all_operations.include? method_name
          @operations << [method_name, args]
        else
          method_name.to_sym
        end
      end

      def label(label_name)
        @labels[label_name] = @operations.size
      end
    end

    def initialize(&block)
      @registers = {ax: 0, bx: 0, cx: 0, dx: 0}
      @last_comparison, @pointer = 0, 0
      storage = Storage.new(&block)
      @operations = storage.operations
      @labels = storage.labels
    end

    def evaluate
      until @pointer == @operations.size
        method_name, args = @operations[@pointer].first, @operations[@pointer].last
        public_send(method_name, *args)
        @pointer = @pointer.succ if !Jumps.instance_methods.include? method_name
      end
      @registers.values
    end
  end

  def self.asm(&block)
    Evaluator.new(&block).evaluate
  end
end
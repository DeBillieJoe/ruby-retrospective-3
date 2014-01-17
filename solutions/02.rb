class Task < Struct.new (:status, :description, :priority, :tags)
  # attr_reader :status, :description, :priority, :tags

  def initialize(status, description, priority, tags = nil)
    @status = status.strip.downcase.to_sym
    @description = description.strip
    @priority = priority.strip.downcase.to_sym
    @tags = tags.split(", ").map(&:strip) unless tags.nil?
  end
end


class TodoList < Struct.new (:task)
  include Enumerable

  def self.parse(text)
    tasks = text.each_line.map do |line|
      Task.new(*line.split('|').map(&:strip))
    end

    new tasks
  end

  def initialize(tasks)
    @tasks = tasks
  end

  def each(&block)
    @tasks.each(&block)
  end

  def filter(criteria)
    TodoList.new tasks.select { |task| criteria.met_by? task }
  end

  def adjoin(other)
    TodoList.new(tasks + other.tasks)
  end

  def tasks_todo
    count { |task| task.status == :todo }
  end

  def tasks_in_progress
    count { |task| task.status == :current }
  end

  def tasks_completed
    count { |task| task.status == :done }
  end

  def completed?
    tasks.length == tasks_completed 
  end
end

class Criteria
  attr_accessor :block

  def initialize(&block)
    @block = block
  end

  def met_by?(task)
    block.call task
  end

  def &(other)
    Criteria.new { |task| met_by? task and other.met_by? task }
  end

  def |(other)
    Criteria.new { |task| met_by? task or other.met_by? task }
  end

  def !(other)
    Criteria.new { |task| not met_by? task }
  end

  class << self
    def status(status)
      Criteria.new { |task| task.status == status }
    end

    def priority(priority)
      Criteria.new { |task| task.priority == priority }
    end

    def tags(tags)
      Criteria.new { |task| tags.all? { |tag| task.tags.include? tag } }
    end
  end
end









# class Criteria
#   def self.status(status)
#     AttributeMatch.new :status, status
#   end

#   def self.priority(priority)
#     AttributeMatch.new :priority, priority
#   end

#   def self.tags(tags)
#     TagsMatch.new tags
#   end
# end

# class AttributeMatch
#   def initialize(attribute, value)
#     @attribute = attribute
#     @value = value
#   end

#   def met_by?(task)
#     task.send(@attribute) == @value
#   end
# end

# class TagsMatches
#   def initialize(tags)
#     @tags = tags
#   end

#   def met_by?(task)
#     @tags.all? { |tag| task.tags.include? tag }
#   end
# end
class Task < Struct.new(:status, :description, :priority, :tags)

  def self.new_from_raw_data(status, description, priority, tags)
    Task.new(
             status.downcase.to_sym,
             description,
             priority.downcase.to_sym,
             tags.split(", ").map(&:strip)
             )
  end
end


class List
  include Enumerable

  attr_accessor :tasks

  def initialize(tasks = [])
    @tasks = tasks
  end

  def each(&block)
    @tasks.each(&block)
  end

  def filter(criteria)
    List.new @tasks.select { |task| criteria.met_by? task }
  end

  def adjoin(other)
    List.new(@tasks + other.tasks)
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
    @tasks.length == tasks_completed
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

  def !
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

module TodoList
  def self.parse(text)
    tasks = text.each_line.map do |line|
      Task.new_from_raw_data(*line.split('|').map(&:strip))
    end

    List.new(tasks)
  end
end


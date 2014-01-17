class TodoList
  include Enumerable

  attr_reader :tasks

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
    TodoList.new @tasks.select { |task| criteria.met_by? task }
  end

  def adjoin(other)
    TodoList.new(tasks + other.tasks)
  end

  alias | adjoin

  def tasks_todo
    (filter Criteria.status(:todo)).tasks.size
  end

  def tasks_in_progress
    (filter Criteria.status(:current)).tasks.size
  end

  def tasks_completed
    (filter Criteria.status(:done)).tasks.size
  end

  def completed?
    tasks.size == tasks_completed
  end
end

class Task
  attr_reader :status, :description, :priority, :tags

  def initialize(status, description, priority, tags = nil)
    @status = status.downcase.to_sym
    @description = description
    @priority = priority.downcase.to_sym
    @tags = tags.split(", ") unless tags.nil?
  end

  def status
    @status
  end

  def priority
    @priority
  end

  def description
    @description
  end

  def tags
    @tags
  end
end

class Criteria
  def self.status(status)
    AttributeMatch.new :status, status
  end

  def self.priority(priority)
    AttributeMatch.new :priority, priority
  end

  def self.tags(tags)
    TagsMatch.new tags
  end
end

class AttributeMatch
  def initialize(attribute, value)
    @attribute = attribute
    @value = value
  end

  def met_by?(task)
    task.send(@attribute) == @value
  end
end

class TagsMatches
  def initialize(tags)
    @tags = tags
  end

  def met_by?(task)
    @tags.all? { |tag| task.tags.include? tag }
  end
end
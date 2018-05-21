require 'colorize'

# task class representing single task
class Task
  attr_accessor :index, :proc_1, :proc_2, :proc_3, :proc_mod

  # init new node
  def initialize(index, m1, m2, m3)
    # data that is read from file
    @index    = index   # task index/number
    @proc_1   = m1      # processing time on first machine
    @proc_2   = m2      # processing time on second machine
    @proc_3   = m3      # processing time on third machine
    # data modified in Johnson's algorithm
    @proc_mod = nil     # modified time calculated in algorithm
    # @color  = 'r'       # color of task, describes the state of it
                            # g(reen) => task is available in system
                            # r(ed)   => outside of system
                            # w(hite) => finished
  end
end

# mydata class holds input
class MyData
  attr_accessor :tasks

  # initialize with empty array of tasks
  def initialize
    @tasks = []
  end

  # search for node with given task index and return it
  def task_with_index(task_index)
    @tasks.each do |task|
      return task if task.index == task_index
    end
    raise ArgumentError, "Task with task number #{task_index} does not exists!"
  end

  # loading graph from file
  def load_from_file(filename)
    File.readlines(filename).each do |line|
      # miss me with that windows format
      line.gsub!(/\r\n?/, "\n")
      # first split by space
      line = line.split(' ')
      raise ArgumentError, 'Missing some input data!' \
        if line.length != 4
      # now split every part of line
      index = line[0].split(':')
      raise ArgumentError, 'Wrong task index data!' \
        if index.length != 2 || index[0] != 'n'
      index = index[1].to_i

      m1 = line[1].split(':')
      raise ArgumentError, 'Wrong machine 1 data!' \
        if m1.length != 2 || m1[0] != 'm1'
      m1 = m1[1].to_i

      m2 = line[2].split(':')
      raise ArgumentError, 'Wrong machine 2 data!' \
        if m2.length != 2 || m2[0] != 'm2'
      m2 = m2[1].to_i

      m3 = line[3].split(':')
      raise ArgumentError, 'Wrong machine 3 data!' \
        if m3.length != 2 || m3[0] != 'm3'
      m3 = m3[1].to_i

      created_task = Task.new(index, m1, m2, m3)
      @tasks << created_task
    end
  end

  # pretty prints N table
  def print_n_array(n_arr)
    print "## tasks: ".light_red
    n_arr.each do |task|
      print task.index.to_s.light_red + " "
    end
    print "\n## mod_t: "
    n_arr.each do |task|
      print task.proc_mod.to_s + " "
    end
    print "\n"
  end

  # pretty prints data
  def print_data(n_one, n_two, c_max)
    puts "-------------------------------------".light_yellow
    puts "------------ Graph data -------------".light_yellow.on_red
    @tasks.each do |task|
      puts "-------------------------------------".light_yellow
      print ("task: " + task.index.to_s).light_red
      print " m1: " + task.proc_1.to_s
      print " m2: " + task.proc_2.to_s
      print " m3: " + task.proc_3.to_s
      puts "\n-------------------------------------".light_yellow
    end
    puts "## More graph/tasks data:".light_yellow.on_red
    puts "## Cmax = #{c_max}".light_cyan
    puts "## N1:".light_cyan
    print_n_array(n_one)
    puts "## N2:".light_cyan
    print_n_array(n_two)
    puts "## For timetable check output folder.".green
    puts "## File is named after argument file.".green
    puts "-------------------------------------".light_yellow
  end
end

# node class representing single node-task in graph
class Node
  attr_accessor :task, :proc_time, :due_time, :rev_time, :prev_tasks,
                :next_tasks, :mod_time, :color, :lateness

  # init new node
  def initialize(task, proc_t, due_t, rev_t, prev_t, next_t)
    # data that is readed from file
    @task       = task            # task index/number
    @proc_time  = proc_t          # time of task execution/processing
    @due_time   = due_t           # time of due task execution
    @rev_time   = rev_t           # time of task reveal
    @prev_tasks = prev_t          # array of tasks right before
    @next_tasks = next_t          # array of tasks right after
    # data modified in liu algorithm
    @mod_time   = nil             # modified time of task's due time
    @color      = 'r'             # color of task, describes the state of it
                                    # g(reen) => exists in system
                                    # r(ed)   => outside of system
                                    # w(hite) => finished
    @lateness   = nil             # lateness of task
  end
end

# mygraph class representing input in form of graph
class MyGraph
  attr_accessor :nodes

  # initialize with empty array of nodes
  def initialize
    @nodes = []
  end

  # loading graph from file
  def load_from_file(filename)
    File.readlines(filename).each do |line|
      # miss me with that windows format
      line.gsub!(/\r\n?/, "\n")
      # first split by space
      line = line.split(' ')
      raise ArgumentError, 'Missing some input data!' \
        if line.length != 6
      # now split every part of line
      task = line[0].split(':')
      raise ArgumentError, 'Wrong task index data!' \
        if task.length != 2 || task[0] != 'n'
      task = task[1].to_i

      proc_t = line[1].split(':')
      raise ArgumentError, 'Wrong processing time data!' \
        if proc_t.length != 2 || proc_t[0] != 'p'
      proc_t = proc_t[1].to_i

      due_t = line[2].split(':')
      raise ArgumentError, 'Wrong due time data!' \
        if due_t.length != 2 || due_t[0] != 'd'
      due_t = due_t[1].to_i

      rev_t = line[3].split(':')
      raise ArgumentError, 'Wrong reveal time data!' \
        if rev_t.length != 2 || rev_t[0] != 'r'
      rev_t = rev_t[1].to_i

      prev_t = line[4].split(':')
      raise ArgumentError, 'Wrong previous tasks data!' \
        if prev_t[0] != 'prev'
      prev_t = prev_t.drop(1).map(&:to_i)

      next_t = line[5].split(':')
      raise ArgumentError, 'Wrong next tasks data!' \
        if next_t[0] != 'next'
      next_t = next_t.drop(1).map(&:to_i)

      created_node = Node.new(task, proc_t, due_t, rev_t, prev_t, next_t)
      @nodes << created_node
    end
  end

  # pretty prints graph data
  def print_graph_data
    puts "-------------------------------------"
    puts "------------ Graph data -------------"
    @nodes.each do |node|
      puts "-------------------------------------"
      print "task: " + node.task.to_s
      print " p: " + node.proc_time.to_s + " d: " + node.due_time.to_s + " r: " +
           node.rev_time.to_s + "\n"
      print "prev: "
      print node.prev_tasks
      print " next: "
      print node.next_tasks
      print "\nnew d: " + node.mod_time.to_s
      print " L: " + node.lateness.to_s
      print " color: " + node.color
      puts "\n-------------------------------------"
    end
  end
end

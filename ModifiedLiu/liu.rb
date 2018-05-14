require './mygraph.rb'
require './timetabledrawer.rb'

###################################################
###                IMPORTANT!!!                 ###
### Node index must start from 1 and be unique. ###
###  0 index is NOT permited in correct input   ###
###     data, please check your input file.     ###
###################################################

# finds minimum value in array
def find_min_in_array(arr)
  raise ArgumentError, 'Array is empty, cannot find minimum!' if arr.empty?
  min_val = arr[0]
  arr.each do |i|
    min_val = i if i < min_val
  end
  return min_val
end

# recursive search of due times in next nodes
def due_time_search(node, graph)
  # insert due time of task
  due_times = [node.due_time]
  node.next_tasks.each do |next_node|
    # break the loop if there is no next nodes
    break if next_node == 0
    # search deeper in recursion
    due_times += due_time_search(graph.node_with_task(next_node), graph)
  end
  return due_times
end

# calculates modified due times for graph
def calculate_modified_due_times(graph)
  graph.nodes.each do |node|
    due_times = []
    # search for all tasks that are connected after it
    due_times += due_time_search(node, graph)
    # find the minimum and pass it to current task
    node.mod_time = find_min_in_array(due_times)
  end
end

# make sure that all tasks are finished
def all_tasks_finished(graph)
  graph.nodes.each do |node|
    # if there is color other than white break
    return false if node.color != 'w'
  end
  return true
end

# mark task with green if task can be run now
def mark_in_system_tasks(curr_time, graph)
  graph.nodes.each do |node|
    # mark only if red, don't mess up done and running tasks
    node.color = 'g' if node.color == 'r' && node.rev_time <= curr_time
  end
end

# find all possible tasks that can be use now
# return array with them
def find_all_possible_tasks(graph)
  possible_now = []
  graph.nodes.each do |node|
    possible_now << node if node.color == 'g'
  end
  return possible_now
end

# if there is atleast one task that is not done return 0
def check_previous_tasks(task, graph)
  task.prev_tasks.each do |prev_node|
    # special case with 0 index, no previous tasks
    break if prev_node == 0
    return false if graph.node_with_task(prev_node).color != 'w'
  end
  return true
end

# filter tasks to make sure they can be run in peace
def filter_tasks_to_run(tasks, graph)
  filter_tasks = []
  tasks.each do |task|
    filter_tasks << task if check_previous_tasks(task, graph)
  end
  return filter_tasks
end

# search for task with lowest modified due time
def find_best_fit_task(tasks)
  # take first one
  chosen_task = tasks[0]
  tasks.each do |task|
    chosen_task = task if task.mod_time < chosen_task.mod_time
  end
  return chosen_task
end

# run task and modify variables in graph structure
def run_task(given_task, curr_time, graph)
  # search in graph for given task
  graph.nodes.each do |node|
    if node.task == given_task.task
      # increase time
      node.pass_time += 1
      # if passed time equals taks processing time
      # mark it with white and calculate lateness
      if node.pass_time == node.proc_time
        node.color = 'w'
        # add one to recompensate array starting from 0
        node.lateness = curr_time - node.due_time + 1
      end
      # go out of loop
      break
    end
  end
  # return task index for timetable
  return given_task.task
end

# tasks scheduling with EDD principle
def modified_liu_algorithm(graph)
  # array that holds the result of scheduling
  # one unit of time is held in cell of array
  timetable = []
  unit_of_time = 0
  # simulate "time" passing by
  # break from loop if all tasks are done
  while !all_tasks_finished(graph)
    # otherwise continue running algorithm
    # look for tasks that can be run
    mark_in_system_tasks(unit_of_time, graph)
    # find all running tasks in system
    tasks = find_all_possible_tasks(graph)
    # skip the step if there are no possible tasks
    if !tasks.empty?
      # make sure they don't depend on previous ones
      tasks = filter_tasks_to_run(tasks, graph)
      # take all tasks that left and find the best fit
      chosen_task = find_best_fit_task(tasks)
      # run selected task and take the index into timetable
      # if task is not selected for reasons, insert 0
      if chosen_task.nil?
        timetable[unit_of_time] = 0
      else
        timetable[unit_of_time] = run_task(chosen_task, unit_of_time, graph)
      end
    else
      # put some 0's on it
      timetable[unit_of_time] = 0
    end
    # increase "time" count
    unit_of_time += 1
  end
  return timetable
end

# read data from input file
if ARGV[0].nil?
  puts "Please enter the name of file!"
  exit
else
  name_of_file = ARGV[0]
end

input_graph = MyGraph.new
input_graph.load_from_file(name_of_file)

calculate_modified_due_times(input_graph)
generated_timetable = modified_liu_algorithm(input_graph)

input_graph.print_graph_data(generated_timetable.length)
input_graph.create_graph_jpg("output/" + ARGV[0])
TimetableDrawer.draw_timetable(generated_timetable, "output/"+ ARGV[0])

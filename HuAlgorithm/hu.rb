require './mygraph.rb'
require './timetabledrawer.rb'

###################################################
###                IMPORTANT!!!                 ###
### Node index must start from 1 and be unique. ###
###  0 index is NOT permited in correct input   ###
###     data, please check your input file.     ###
###################################################

# add root node to graph and connect it to nodes with nil nexts
def add_root_node(graph)
  # initialize root node with -1 index of task and processing time
  # add empty table of previous nodes and [0] of next nodes
  root_node = Node.new(-1, 0, [], [0])
  # search in graph for tasks that "goes out"
  graph.nodes.each do |node|
    root_node.prev_tasks << node.task if node.next_tasks == [0]
  end
  # push the root to graph nodes
  graph.nodes << root_node
end

# recursive method to set nodes levels
def nodes_level_search(node, curr_level, graph)
  node.level = curr_level
  node.prev_tasks.each do |prev_node|
    break if prev_node == 0
    # make sure that works with complicated relations
    nodes_level_search(graph.node_with_task(prev_node), curr_level + 1, graph)
  end
  # return
end

# set node levels, starting from root
def calculate_nodes_level(graph)
  graph.nodes.each do |node|
    # start recursion with level 0 from root which index is -1
    nodes_level_search(node, 0, graph) if node.task == -1
  end
end

# make sure that all tasks are finished
# that means only root node is left with 'r' or 'g' (?)
def all_tasks_finished(graph)
  graph.nodes.each do |node|
    # if there is color other than white break
    return false if node.color != 'w' && node.task != -1
  end
  return true
end

# if there is atleast one task that is not done return false
def check_previous_tasks(task, graph)
  task.prev_tasks.each do |prev_node|
    # special case with 0 index, no previous tasks
    break if prev_node == 0
    return false if graph.node_with_task(prev_node).color != 'w'
  end
  return true
end

# mark task with green if task can be run now
def mark_in_system_tasks(graph)
  graph.nodes.each do |node|
    # mark only if red, don't mess up done and running tasks
    node.color = 'g' if node.color == 'r' && check_previous_tasks(node, graph)
  end
end

# check if the node is already in the list
def check_task_in_list(priority_list, node)
  priority_list.each do |element|
    # if node is in list return nil
    return true if element.task == node.task
  end
  return false
end

# find all possible tasks that can be use now
# return new list with them
def find_all_possible_tasks(priority_list, graph)
  graph.nodes.each do |node|
    puts "node " + node.task.to_s + node.color
    # add node to priority_list
    priority_list << node if node.color == 'g' && !check_task_in_list(priority_list, node)
  end
  return priority_list
end

# pretty print on step of algorithm
def print_step_of_algorithm(priority_list, unit_of_time)
  print "List " + unit_of_time.to_s + ": ("
  i = 0
  priority_list.each do |element|
    if i < priority_list.length - 1
      print element.task.to_s + ", "
    else
      print element.task.to_s
    end
    i += 1
  end
  print ")\n"
end

def hu_algorithm(graph, number_of_machines)
  # create empty timetable and empty priority list for tasks
  priority_list = []
  # allocate empty timetable for machines
  timetable = Array.new(number_of_machines){Array.new()}
  # simulate "time" passing by
  # break from loop if all tasks are done
  unit_of_time = 0
  while !all_tasks_finished(graph)
    # mark available tasks in system
    mark_in_system_tasks(graph)
    # look for new priority list
    priority_list = find_all_possible_tasks(priority_list, graph)
    # print step of algorithm
    print_step_of_algorithm(priority_list, unit_of_time)
    # skip the step if priority list is empty
    if !priority_list.empty
      
    else
      fill_timetable(timetable, tasks)
    end
    # increase "time" count
    unit_of_time += 1
  end
  puts "error" if !priority_list.empty?
  return timetable
end

# read data from input file
if ARGV[0].nil?
  puts "Please enter the name of file!"
  exit
else
  name_of_file = ARGV[0]
end

# number of machines is given by user as parameter
if ARGV[1].nil?
  puts "Please enter number of machines!"
  exit
elsif ARGV[1] == 0
  puts "Number of machines should be more than 0!"
  exit
else
  number_of_machines = ARGV[1].to_i
end

input_graph = MyGraph.new
input_graph.load_from_file(name_of_file)

add_root_node(input_graph)
calculate_nodes_level(input_graph)

generated_timetable = hu_algorithm(input_graph, number_of_machines)

input_graph.print_graph_data()

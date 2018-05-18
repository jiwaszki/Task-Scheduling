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
  number_of_machines = ARGV[1]
end

input_graph = MyGraph.new
input_graph.load_from_file(name_of_file)

add_root_node(input_graph)
calculate_nodes_level(input_graph)



input_graph.print_graph_data()

require 'rgl/adjacency'
require 'rgl/dot'

# remove given index from depends array
def remove_dependent(nodes, remove_index)
  nodes.each do |node|
    if node != nil && node.depends != nil
      node.depends.each do |depend|
        if depend == remove_index
          node.depends = node.depends - [remove_index]
        end
      end
    end
  end
end

# returns sorted array with nodes' indexes
# if returns 1 it means that there is cycle in graph -> error code
def topological_sort(original_graph)
  sorted_arr = []

  graph = MyGraph.new
  graph = original_graph

  # make sure there is at least one node with no dependents
  # find all nodes with no dependents and take them out to array
  graph.nodes.each do |node|
    if node != nil && node.depends == nil
      sorted_arr << node.index
      # remove dependents from other nodes
      remove_dependent(graph.nodes, node.index)
      node = nil
    end
  end
  # return error code when above statement isn't true
  return 1 if sorted_arr.empty?

  # go for the rest of graph, empty depends means zero degree
  i = 0
  while i < graph.nodes.length
    if graph.nodes[i] != nil && graph.nodes[i].depends == []
      sorted_arr << graph.nodes[i].index
      # remove dependents from other nodes
      remove_dependent(graph.nodes, graph.nodes[i].index)
      # and remove node from graph
      graph.nodes[i] = nil
      i = 0
    else
      # next node
      i += 1
    end
  end

  # not sure if != or just <
  return 1 if sorted_arr.length != graph.nodes.length
  return sorted_arr
end

# given array of sorted nodes change the indexes in graph
# returns new graph with changes
def topological_change(old_graph, sorted_arr)
  # creates new graph
  new_graph = MyGraph.new
  # take each of sorted index, change and add node to new graph
  # we know that sorted_arr and old_graph lengths are equal but to be sure
  if old_graph.nodes.length != sorted_arr.length
    puts "Graph and sorted array are not the same length!"
    exit
  end
  # copy the nodes in new order
  (0...sorted_arr.length).each do |i|
    # look for node with this index
    old_graph.nodes.each do |node|
      if node != nil && node.index == sorted_arr[i]
        # copy node and add it to new graph
        tmp_node = Node.new(i, node.task, node.time, node.label, node.depends)
        new_graph.nodes << tmp_node
        # delete node, no longer use
        node = nil
        break
      end
    end
  end
  # change the dependents to match new order
  new_graph.nodes.each do |node|
    if node.depends != nil
      (0...node.depends.length).each do |j|
        (0...sorted_arr.length).each do |i|
          if node.depends[j] == sorted_arr[i]
            node.depends[j] = i
            break
          end
        end
      end
    end
  end

  return new_graph
end

class Node
  attr_accessor :index, :task, :time, :label, :depends, :used
  # init of node
  def initialize(i, task, time, l, arr)
    @index = i        # index of node
    @task = task      # task number
    @time = time      # time of task execution
    @label = l        # label of task node
    @depends = arr    # array of nodes before, node depends on them
    @used = 0         # attribute used in creating timetable
  end
end

class MyGraph
  attr_accessor :nodes
  # initialize with empty array of nodes
  def initialize
    @nodes = []
  end

  # loading graph from file, example:
  # number_of_task time_of_execution depends_on
  # 1 5
  # 4 2 2 3
  def load_from_file(filename)
    # opens file and read line by line
    File.readlines(filename).each do |line|
      # miss me with that windows format
      line.gsub!(/\r\n?/, "\n")
      line = line.split
      line = line.map(&:to_i)
      # create node
      if line.length < 2
        puts "There is some wrong input in file!"
        exit
      elsif line.length == 2
        tmp_node = Node.new(line[0], line[0], line[1], nil, nil)
        @nodes << tmp_node
      else
        tmp_arr = []
        (2...line.length).each do |i|
          tmp_arr << line[i]
        end
        tmp_node = Node.new(line[0], line[0], line[1], nil, tmp_arr)
        @nodes << tmp_node
      end
    end
  end

  def pretty_name(node)
    new_name = node.index.to_s + "\nZ" + node.task.to_s + "\np: " + \
               node.time.to_s + "\nl: " + node.label.to_s
  end

  def create_graph_jpg(filename)
    visualisation = RGL::DirectedAdjacencyGraph[]

    @nodes.each do |node|
      node_name = pretty_name(node)
      visualisation.add_vertex(node_name)
      if node.depends != nil
        node.depends.each do |dependent|
          @nodes.each do |find|
            if dependent == find.index
              dependent_name = pretty_name(find)
              visualisation.add_edge(dependent_name, node_name)
              break
            end
          end
        end
      end
    end

    visualisation.write_to_graphic_file('jpg', filename)
    # delete .dot file
    system("rm -f " + filename + ".dot")
  end

  # dunno the term for "zależności kolejnościowe"
  def create_depending_jpg(filename)
    visualisation = RGL::DirectedAdjacencyGraph[]

    @nodes.each do |node|
      node_name = pretty_name(node)
      visualisation.add_vertex(node_name)
      if node.depends != nil
        max_val = 0
        old_max = 0
        max_node = Node.new(nil, nil, nil, nil, nil)
        node.depends.each do |dependent|
          @nodes.each do |find|
            if dependent == find.index
              max_val = pick_max(find.label + find.time, max_val)
              if max_val != old_max
                old_max = max_val
                max_node = find
              end
            end
          end
        end
        dependent_name = pretty_name(max_node)
        visualisation.add_edge(dependent_name, node_name)
      end
    end

    visualisation.write_to_graphic_file('jpg', filename)
    # delete .dot file
    system("rm -f " + filename + ".dot")
  end
end

require "./mygraph.rb"

# module implements topological sort and other created method
# that
module CycleFinder
  # remove given index from nodes array
  def self.remove_task(graph, remove_index)
    graph.nodes.each do |node|
      if node != nil
        # look inside previous tasks
        if node.prev_tasks != [0]
          node.prev_tasks.each do |prev_t|
            if prev_t == remove_index
              node.prev_tasks = node.prev_tasks - [remove_index]
            end
          end
        end
        # now check in next
        if node.next_tasks != [0]
          node.next_tasks.each do |next_t|
            if next_t == remove_index
              node.next_tasks = node.next_tasks - [remove_index]
            end
          end
        end
      end
    end
  end

  # returns 0 when array matches means that graph has no cycles
  # if returns 1 it means that there is cycle in graph -> error code
  def self.has_cycle_topological_sort(original_graph)
    sorted_arr = []
    graph = MyGraph.new
    graph.nodes = copy_nodes(original_graph)

    # print graph.nodes
    # make sure there is at least one node with no dependents
    # find all nodes with no dependents and take them out to array
    graph.nodes.each do |node|
      if node != nil && node.prev_tasks == [0]
        sorted_arr << node.task
        # remove dependents from other nodes
        remove_task(graph, node.task)
        node = nil
      end
    end
    # return error code when above statement isn't true
    return 1 if sorted_arr.empty?

    # go for the rest of graph, empty depends means zero degree
    i = 0
    while i < graph.nodes.length
      if graph.nodes[i] != nil && graph.nodes[i].prev_tasks == []
        sorted_arr << graph.nodes[i].task
        # remove dependents from other nodes
        remove_task(graph, graph.nodes[i].task)
        # and remove node from graph
        graph.nodes[i] = nil
        i = 0
      else
        # next node
        i += 1
      end
    end

    return 1 if sorted_arr.length != graph.nodes.length
    return 0
  end

  # go to parents of node and return array of them
  def self.go_to_parents(node, graph)
    parents = [node.task]
    node.prev_tasks.each do |prev_node|
      # break if there is no previous nodes
      break if prev_node == 0
      # go to parents
      parents += go_to_parents(graph.node_with_task(prev_node), graph)
    end
    return parents
  end

  # use DFS-like method to check if tree is valid
  def self.check_if_in_tree(original_graph)
    graph = MyGraph.new
    graph.nodes = copy_nodes(original_graph)
    # start from root and go up
    graph.nodes.each do |node|
      if node.task != -1
        parents = []
        parents += go_to_parents(node, graph)
        # look for duplicates or not existing nodes in array
        # using counting method
        parents.each do |element|
          # if there is error code stop program
          return 1 if graph.add_count_to_task(element) == 1
        end
        # reste the count in graph
        graph.nodes.each do |clean_node|
          clean_node.count = 0
        end
      end
    end
    # if there is no duplicate return 0
    return 0
  end
end

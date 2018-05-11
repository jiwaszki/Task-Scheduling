require './mygraph.rb'
require 'rmagick'

def pick_max(a, b)
  if a > b
    a
  else
    b
  end
end

def pick_min(a, b)
  if a <= b
    return a
  else
    return b
  end
end

# label source nodes with 0's
def label_source_nodes(graph)
  graph.nodes.each do |node|
    if node.depends == nil
      node.label = 0
    end
  end
end

# label rest of the nodes in graph
def label_next_nodes(graph)
  graph.nodes.each do |node|
    if node.depends != nil
      max_val = 0
      node.depends.each do |dependent|
        graph.nodes.each do |find|
          if dependent == find.index
            max_val = pick_max(find.label + find.time, max_val)
          end
        end
      end
      node.label = max_val
    end
  end
end

# creates timetable for graph with tasks
def create_timetable(graph)
  # look for maximum ending time
  max_end = 0
  graph.nodes.each do |node|
    max_val = pick_max(max_end, node.label + node.time)
    max_end = max_val if max_val != max_end
  end

  if max_end == 0
    puts "There are no tasks?"
    exit
  end

  # create new 2d array for timetable
  timetable = Array.new(max_end){Array.new()}
  col_number = 0

  # take first not used node
  i = 0
  while i < graph.nodes.length
    if graph.nodes[i].used == 0
      # search for lowest label starting from this node
      lowest_index = i
      lowest_label = graph.nodes[i].label
      (i...graph.nodes.length).each do |j|
        if graph.nodes[j].used == 0
          new_lowest = pick_min(lowest_label, graph.nodes[j].label)
          if lowest_label != new_lowest
            lowest_index = j
            lowest_label = new_lowest
          end
        end
      end
      # put found "lowest" task in array, search in col first
      if col_number == 0
        # fill first row with "x"
        (0...timetable.length).each do |r|
          timetable[r] << "x"
        end
        # now fill span with task
        span = graph.nodes[lowest_index].label + graph.nodes[lowest_index].time
        (graph.nodes[lowest_index].label...span).each do |r|
          timetable[r][col_number] = graph.nodes[lowest_index].task.to_s
        end
        col_number += 1
      else
        # look for free row with span
        free_col = 0
        free_col_index = 0
        span = graph.nodes[lowest_index].label + graph.nodes[lowest_index].time
        (0...col_number).each do |c|
          free_col = 0
          (graph.nodes[lowest_index].label...span).each do |r|
            if timetable[r][c] != "x"
              free_col = 1
              break
            end
          end
          if free_col == 0
            free_col_index = c
            break
          elsif c == col_number - 1
            if free_col == 0
              free_col_index = c
              break
            else
              free_col = 1
              break
            end
          end
        end
        if free_col == 1
          # if there is no free column create new one
          (0...timetable.length).each do |r|
            # [r][col_number+1] ???
            timetable[r] << "x"
          end
          # now fill span with task
          (graph.nodes[lowest_index].label...span).each do |r|
            timetable[r][col_number] = graph.nodes[lowest_index].task.to_s
          end
          col_number += 1
        else
          # if there is free column fill it
          (graph.nodes[lowest_index].label...span).each do |r|
            timetable[r][free_col_index] = graph.nodes[lowest_index].task.to_s
          end
        end
      end
      # mark node as used
      graph.nodes[lowest_index].used = 1
      # restart loop
      i = 0
    else
      i += 1
    end
  end

  return timetable, max_end
end

# draw timetable
def draw_timetable(timetable, table_end, name_of_file, fixed_size = 100)
  # transpose the table
  timetable = timetable.transpose

  imgl = Magick::ImageList.new
  imgl.new_image((table_end) * fixed_size + fixed_size / 2,
                 (timetable.length + 1) * fixed_size + fixed_size / 2,
                 Magick::HatchFill.new('white','lightcyan2'))

  (0...timetable.length).each do |i|
    if i == 0
      f_y = 0
      s_y = 0
    else
      f_y = i * (fixed_size + 1)
      s_y = i * fixed_size
    end
    (0...table_end).each do |j|
      if j == 0
        f_x = 0
        s_x = 0
      else
        f_x = j * (fixed_size + 1)
        s_x = j * fixed_size
      end

      square = Magick::Draw.new

      if timetable[i][j] == "x"
        square.fill_opacity(20)
        square.stroke_width(fixed_size / 20)
        square.stroke('#292925')
        square.fill('#56574F')
        square.rectangle(s_x, s_y, s_x + fixed_size, s_y + fixed_size)
        square.draw(imgl)
      else
        square.fill_opacity(100)
        square.stroke_width(fixed_size / 20)
        square.stroke('#292925')
        square.fill('#BBBDAC')
        square.rectangle(s_x, s_y, s_x + fixed_size, s_y + fixed_size)
        square.draw(imgl)

        txt = Magick::Draw.new

        txt.font_weight(Magick::NormalWeight)
        txt.font_style(Magick::NormalStyle)
        txt.pointsize(fixed_size / 3)
        txt.fill('#1F1F57')
        txt.stroke('transparent')
        txt.text(s_x + fixed_size / 8, s_y + fixed_size / 2, "Z" + timetable[i][j])

        txt.draw(imgl)
      end
    end
  end

  # draw timeline
  t_x = table_end * fixed_size
  t_y = (timetable.length + 1) * fixed_size - fixed_size / 2

  timeline = Magick::Draw.new

  timeline.fill('#292925')
  timeline.stroke('#292925').stroke_width(fixed_size / 10)
  timeline.line(0, t_y, t_x, t_y)
  # make dots
  (0..table_end).each do |k|
    timeline.circle(k * fixed_size, t_y,
                    k * fixed_size + 2, t_y + fixed_size / 10)
    # label the dot
    dot = Magick::Draw.new

    dot.font_weight(Magick::NormalWeight)
    dot.font_style(Magick::NormalStyle)
    dot.pointsize(fixed_size / 3)
    dot.fill('#292925')
    dot.stroke('transparent')
    dot.text(k * fixed_size, t_y + fixed_size / 2, k.to_s)

    dot.draw(imgl)
  end
  timeline.draw(imgl)

  imgl.border!(5,5, '#292925')
  imgl.write(name_of_file + ".gif")
end

# transpose-like print
def print_timetable(timetable, table_end)

  timetable = timetable.transpose

  # normal print method for array
  (0...timetable.length).each do |i|
    (0...table_end).each do |j|
      print "|" + timetable[i][j] + "|"
    end
    print "\n"
  end

end

if ARGV[0].nil?
  puts "Enter the name of file!"
  exit
else
  name_of_file = ARGV[0]
end

input_graph = MyGraph.new
input_graph_copy = MyGraph.new
topological_graph = MyGraph.new

# need to read both 'cause simple = makes a reference
input_graph.load_from_file(name_of_file + '.txt')
input_graph_copy.load_from_file(name_of_file + '.txt')

print "Order before topological sort:\t"
input_graph.nodes.each do |node|
  print node.index.to_s + " "
end
print "\n"

# input_graph.create_graph_jpg(name_of_file + '_graph')

# return array of sorted nodes
sort_index = topological_sort(input_graph_copy)

# here use array to make things right
if sort_index == 1
  puts "Graph is not topological!"
  exit
else
  print "Order after topological sort:\t"
  sort_index.each do |i|
    print i.to_s + " "
  end
  print "\n"
end

# rearrange graph with info from sorted array
topological_graph = topological_change(input_graph, sort_index)
# mark source nodes with 0's
label_source_nodes(topological_graph)
# next step in algorithm
label_next_nodes(topological_graph)
# create graph for preview
topological_graph.create_graph_jpg('./output/' + name_of_file + '_graph')

# no need for this in project
topological_graph.create_depending_jpg('./output/' + name_of_file + '_depending')

# method marks nodes as used
timetable, table_end = create_timetable(topological_graph)
# C*max is the end of timetable
puts "C*max is equal to " + table_end.to_s
# print_timetable(timetable, table_end)
draw_timetable(timetable, table_end,
               './output/' + name_of_file + '_timetable', 100)

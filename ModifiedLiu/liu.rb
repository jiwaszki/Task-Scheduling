require './mygraph.rb'

###################################################
###                 IMPORTANT!!!                ###
### Node index must start from 1 and be unique. ###
###  0 index is NOT permited in correct input   ###
###     data, please check your input file.     ###
###################################################

# read data from input file
if ARGV[0].nil?
  puts "Please enter the name of file!"
  exit
else
  name_of_file = ARGV[0]
end

input_graph = MyGraph.new
input_graph.load_from_file(name_of_file + '.txt')
input_graph.print_graph_data

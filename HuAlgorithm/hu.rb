require './mygraph.rb'
require './timetabledrawer.rb'

###################################################
###                IMPORTANT!!!                 ###
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

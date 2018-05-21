require './mydata.rb'
require './timetabledrawer.rb'

###################################################
###                IMPORTANT!!!                 ###
### Node index must start from 1 and be unique. ###
###  0 index is NOT permited in correct input   ###
###     data, please check your input file.     ###
###                  PROBLEM:                   ###
###                  F3||Cmax                   ###
###################################################



# read data from input file
if ARGV[0].nil?
  puts "Please enter the name of file!"
  exit
else
  name_of_file = ARGV[0]
end

input_data = MyData.new
input_data.load_from_file(name_of_file)

input_data.print_data()
# TimetableDrawer.draw_timetable(generated_timetable, c_max, "output/"+ ARGV[0])

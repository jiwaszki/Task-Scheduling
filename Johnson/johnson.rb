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

# number of machines predefined in the problem
$number_of_machines = 3

# check if the algorithm starting conditions are valid
# for the first machine
def domination_of_first_machine(data)
  data.tasks.each do |task1|
    data.tasks.each do |task2|
      return false if task1.proc_1 < task2.proc_2
    end
  end
  return true
end

# check if the algorithm starting conditions are valid
# for the third machine
def domination_of_third_machine(data)
  data.tasks.each do |task1|
    data.tasks.each do |task2|
      return false if task1.proc_3 < task2.proc_2
    end
  end
  return true
end

# calculates modified times from tasks
# returns two arrays N1 and N2
def calculate_modified_times(data)
  # arrays of divided tasks
  n_one = []
  n_two = []
  # t1 is calculated from first and second machine processing time
  # t2 is calculated from second and third machine processing time
  data.tasks.each do |task|
    t_one = task.proc_1 + task.proc_2
    t_two = task.proc_2 + task.proc_3
    # if t1 modified time has less than t2, push it to N1
    if t_one < t_two
      task.proc_mod = t_one
      n_one << task
    else
      # otherwise push t2 into N2
      task.proc_mod = t_two
      n_two << task
    end
  end
  # sort N1 and N2, N1 in not desc order, N2 in not asc order
  n_one.sort! { |a,b| a.proc_mod <=> b.proc_mod }
  n_two.sort! { |a,b| b.proc_mod <=> a.proc_mod }
  # return sorted arrays
  return n_one, n_two
end

# fill array with symbol n times
def fill_array_with_symbol(arr, symbol, times)
  (0...times).each do |i|
    arr << symbol
  end
  return arr
end

# find where the task ends in array
def find_end_of_task(arr, task)
  found_index = nil
  search_flag = false
  (0...arr.length).each do |i|
    # break from loop if task changes and search_flag is set true
    break if arr[i] != task.index && search_flag
    # search for the first occurrence of task
    if arr[i] == task.index
      # set search flag to true
      search_flag = true
      # update found index with i
      found_index = i + 1
    end
  end
  # if found index is still nil return 0
  if found_index.nil?
    puts "Task #{task.index} was not found in previous array."
    return 0
  else
    return found_index
  end
end

# use given N array to fill the machine
def use_n_table_to_fill(timetable, n, m)
  n.each do |task|
    # find where given task ends in machine number one
    start_index = find_end_of_task(timetable[m - 1], task) if m > 0
    # skip the step when it is machine number one
    if m > 0 && timetable[m].length < start_index
      # put 0's to fill the gap
      timetable[m] = fill_array_with_symbol(timetable[m], 0, start_index - timetable[m].length)
    end
    # and add task to timetable
    timetable[m] = fill_array_with_symbol(timetable[m], task.index, task.proc_1) if m == 0
    timetable[m] = fill_array_with_symbol(timetable[m], task.index, task.proc_2) if m == 1
    timetable[m] = fill_array_with_symbol(timetable[m], task.index, task.proc_3) if m == 2
  end
  return timetable
end

# use N tables to fill the machines with tasks
def filling_procedure(timetable, n_one, n_two, machine)
  # use N1 first and than N2
  timetable = use_n_table_to_fill(timetable, n_one, machine)
  timetable = use_n_table_to_fill(timetable, n_two, machine)
  return timetable
end

def find_cmax_in_timetable(timetable)
  c_max = 0
  (0...timetable.length).each do |i|
    c_max = timetable[i].length if c_max < timetable[i].length
  end
  return c_max
end

def johnson_algorithm(data)
  # check the starting conditions in algorithm
  if !domination_of_first_machine(data) || !domination_of_third_machine(data)
    puts "Neither first nor third machine dominates the second!"
    exit
  end
  # get needed arrays with tasks and modified processing times
  n_one, n_two = calculate_modified_times(data)
  # create "permutation" timetable from N1 and N2
  timetable = Array.new($number_of_machines){Array.new()}
  # fill the first machine with tasks
  timetable = filling_procedure(timetable, n_one, n_two, 0)
  # the second machine
  timetable = filling_procedure(timetable, n_one, n_two, 1)
  # and the third
  timetable = filling_procedure(timetable, n_one, n_two, 2)
  # return timetable, N1 and N2 for printing
  return timetable, n_one, n_two
end

# read data from input file
if ARGV[0].nil?
  puts "Please enter the name of file!"
  exit
else
  name_of_file = ARGV[0]
end

input_data = MyData.new
input_data.load_from_file(name_of_file)

generated_timetable, n_one, n_two = johnson_algorithm(input_data)
c_max = find_cmax_in_timetable(generated_timetable)

input_data.print_data(n_one, n_two, c_max)
TimetableDrawer.draw_timetable(generated_timetable, c_max, "output/"+ ARGV[0])

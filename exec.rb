require './filediff'
include FileDiffer

begin
  puts 'Use files from example?(Y/N):'
  use_files = gets.chomp
end until %w(y n).include?(use_files.downcase)

if use_files.downcase == 'y'
  filediff = FileDiff.new('example/text1.txt', 'example/text2.txt')
else
  puts 'Input path for the 1st file:'
  file1_path = gets.chomp

  puts 'Input path for the 2d file:'
  file2_path = gets.chomp

  filediff = FileDiff.new(file1_path, file2_path)
end

filediff.compare(true)

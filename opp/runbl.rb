#!/usr/bin/env ruby
require_relative "./parser.rb"

# File for easily running the program and setting some flags for the program that one may want to use
# -tree  : Prints the whole tre structure of the program in a nice tree
# -debug : Enables rdparse debug
# -norun : Makes the program not run after parsing

if(ARGV.length == 0)
    raise "No arguments given"
end

filename = ARGV[ARGV.length - 1]

parser = BaljanLang.new()
parser.log(false)

no_run = false

# Sets all potential flags
ARGV.each_with_index do |arg, index|
    if(index > ARGV.length - 2)
        break
    end

    if(arg.downcase == "-tree")
        parser.print_tree = true
    elsif(arg.downcase == "-debug")
        parser.log(true)
    elsif(arg.downcase == "-norun")
        no_run = true
    end
end

# Parse the file
parser.parse_file(filename)

# Run the program if no run is off
if(not no_run)
    parser.run()
end
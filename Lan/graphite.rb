#!/usr/bin/env ruby
require './language.rb'

$l = LanguageParser.new()
$parse_times = []

def done(str)
    ["quit","exit","bye","done",""].include?(str.chomp)
end

def read_file(filename)
    file = IO.readlines(filename, chomp: true)
    file = file.join(" ")

    parse_code(file)
end

def parse_code(data)
    time1 = Time.now
    return_value = eval($l.language_parser.parse(data))
    time2 = Time.now
    elapsed_time = time2 - time1
    puts "Parse time: #{elapsed_time} seconds"
    $parse_times << elapsed_time
    return return_value
end

def execute(data)
    if done(data)
        pass
    else
        output=parse_code(data)
        puts("Max parse time: #{$parse_times.max()}")
        return output
    end
end

def log(state = false)
    if state
        @diceParser.logger.level = Logger::DEBUG
    else
        @diceParser.logger.level = Logger::WARN
    end
end

def read_code
    ARGV.clear
    print "[Graphite] "
    input = gets
    if done(input) then
      puts "Bye."
    else
      puts "=> #{parse_code(input)}"
      read_code
    end
end

input_array = ARGV

if input_array.size == 1
    if input_array[0] == "gph"
        read_code
    else
        read_file(input_array[0])
    end
end

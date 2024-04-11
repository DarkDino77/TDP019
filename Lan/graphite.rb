#!/usr/bin/env ruby
require './language.rb'

$l = LanguageParser.new()
$parse_times = []
$slowest_code = ""

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
    return_value = $l.language_parser.parse(data)
    if $debug
        time2 = Time.now
        elapsed_time = time2 - time1
        puts "Parse time: \e[01m#{elapsed_time}\e[00m seconds"
        $parse_times << elapsed_time
        if elapsed_time == $parse_times.max()
            $slowest_code = data
        end
    end
    return return_value
end

def execute(data)
    if done(data)
        pass
    else
        output=parse_code(data)
        if $debug
            puts("Max parse time: \e[01m#{$parse_times.max()}\e[00m seconds")
            puts("Average parse time: \e[01m#{$parse_times.inject{ |sum, el| sum + el }.to_f / $parse_times.size}\e[00m seconds")
            puts("Slowest code: \e[01m#{$slowest_code}\e[00m")
            puts "===========================================================================\n\n"
        end
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
        puts "
  _____                 _     _ _       
 / ____|               | |   (_) |      
| |  __ _ __ __ _ _ __ | |__  _| |_ ___ 
| | |_ | '__/ _` | '_ \\| '_ \\| | __/ _ \\
| |__| | | | (_| | |_) | | | | | ||  __/ 
 \\_____|_|  \\__,_| .__/|_| |_|_|\\__\\___|
                 | |                    
                 |_|                    
        "
        read_code
    else
        read_file(input_array[0])
    end
end

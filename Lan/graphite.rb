#!/usr/bin/env ruby
require './language.rb'

$l = LanguageParser.new()

def done(str)
    ["quit","exit","bye","done",""].include?(str.chomp)
end

def read_file(filename)
    file = IO.readlines(filename, chomp: true)
    file = file.join(" ")

    parse_code(file)
end

def parse_code(data)
    return eval($l.language_parser.parse(data))
end

def execute(data)
    if done(data)
        pass
    else
        output=parse_code(data)
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

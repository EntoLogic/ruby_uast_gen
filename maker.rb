#!/usr/bin/env ruby
#  ________           _          _____                     _          
# |_   __  |         / |_       |_   _|                   (_)         
#   | |_ \_| _ .--. `| |-' .--.   | |       .--.   .--./) __   .---.  
#   |  _| _ [ `.-. | | | / .'`\ \ | |   _ / .'`\ \/ /'`\;[  | / /'`\] 
#  _| |__/ | | | | | | |,| \__. |_| |__/ || \__. |\ \._// | | | \__.  
# |________|[___||__]\__/ '.__.'|________| '.__.' .',__` [___]'.___.' 
#                                                ( ( __))             
# Copyright © Entologic
#
# Ruby uni-ast-gen

require 'ripper'
require 'ap'
require 'pp'
require 'json'

def transform_hash(original, options={}, &block)
  original.inject({}) do |result, (key,value)|
    value = if (options[:deep] && Hash === value) 
              transform_hash(value, options, &block)
            else 
              value
            end
    block.call(result,key,value)
    result
  end
  # Thanks to Avdi Grimm for this handi method.
end

require_relative 'lib/ast_node_classes'
require_relative 'lib/to_json'

if ARGV[0]
  begin
    input_file = File.read ARGV[0]
  rescue
    abort("Could not read file '" + ARGV[0] + "'")
  end
else
  input_file = STDIN.read
end

ripper_ast = Ripper.sexp(input_file)

hash_uast = {
  "Meta" => { "Language" => "Ruby" },
  "Program" => []
}

base_node_list = statements_list(ripper_ast[1])

hash_uast["Program"] = handle_array_of_nodes(base_node_list)

if ARGV.include?("-d")
  pp ripper_ast
  pp base_node_list
  puts JSON.pretty_generate(hash_uast)
else
  STDOUT.print(hash_uast.to_json)
end
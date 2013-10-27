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

require_relative 'ast_node_classes.rb'
require_relative 'to_json.rb'
abort("Must supply a program") unless ARGV[0]

input_file = File.read ARGV[0] + ".rb"
ripper_ast = Ripper.sexp(input_file)

hash_uast = {
  "Meta" => { "Language" => "Ruby" },
  "Program" => []
}

base_node_list = ripper_ast[1].map do |stmt|
  UastNode.uast_node_from_rtree(stmt)
end

pp base_node_list
hash_uast["Program"] = handle_array_of_nodes(base_node_list)
uast_json = hash_uast.to_json
puts uast_json


# Copyright © Entologic
#
# Ruby uni-ast-gen

# OLD ripper version

require 'ripper'
require_relative 'ast_node_classes.rb'
abort("Must supply a program") unless ARGV[0]

input_file = File.read ARGV[0] + ".rb"
ripper_ast = Ripper.sexp(input_file)

output_hash_uast = { Meta: { Language: "Ruby" } }

base_node_list = ripper_ast[1].map do |stmt|
  UastNode.uast_node_from_rtree(stmt)
end

pp base_node_list

# def get_all_statments_in(ast_node)
#   list = []
#   list.unshift(ast_node.last) if ast_node.is_a?(Array)
#   list = get_all_statments_in(ast_node[-2]) + list if ast_node.is_a?(Array)
#   return list
# end

# def deep_search(arr, term)
#   list = []
#   arr.each do |el|
#     if el == term
#       list << el
#     elsif el.is_a?(Array)
#       if el[0] == term
#         list << el.last
#       else
#         list << deep_search(el, term)
#       end
#     end
#   end
#   return list.flatten
# end
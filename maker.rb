# Copyright © Entologic
#
# Ruby uni-ast-gen

require 'ripper'
require_relative 'ast_node_classes.rb'

ripper_ast = Ripper.sexp(ARGV[0])

output_hash_uast = { Meta: { Language: "Ruby" } }

base_node_list = ripper_ast[1].map do |stmt|
  Uast.uast_node_from_rtree(stmt)
end

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
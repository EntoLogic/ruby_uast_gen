# Copyright © Entologic
#
# Ruby uni-ast-gen

require 'ripper'
require 'ap'
require 'pp'
require 'json'

require_relative 'ast_node_classes.rb'
abort("Must supply a program") unless ARGV[0]

input_file = File.read ARGV[0] + ".rb"
ripper_ast = Ripper.sexp(input_file)

huast = {
  Meta: { Language: "Ruby" },
  Program: []
}

base_node_list = ripper_ast[1].map do |stmt|
  UastNode.uast_node_from_rtree(stmt)
end

pp base_node_list
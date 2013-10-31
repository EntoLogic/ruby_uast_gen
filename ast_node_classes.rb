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

def ruby_op_name(op_sym)
  case op_sym
  when :+ then "add"
  when :- then "subtract"
  when :* then "multiply"
  when :/ then "divide"
  end
end

def var_field_str(vf)
  vf[1][1]
end

class UastNode
  attr_reader :child_nodes

  def initialize(node)
    @node = node
    @loc  = node.last if node[0][0] == "@"
  end

  def self.uast_node_from_rtree(rnode)
    case rnode[0]
      when :binary    then BinaryNode.new(rnode)
      when :def       then DefineNode.new(rnode)
      when :assign    then AssignmentNode.new(rnode)
      when :var_field then var_field_str(rnode)

      # @-sign ones (I think they are for literals)
      when :@int      then IntLitNode.new(rnode)

      # Unknowen
      else UnknowenNode.new(rnode)
    end
  end

  def to_hash
    hash = {}
    instance_variables.map {|var| hash[var.to_s.delete("@")] = instance_variable_get(var) }
    hash
  end
end

class UnknowenNode < UastNode
  def initialize(node)
    super(node)
  end
end

class BinaryNode < UastNode
  UAST_NODE_NAME = "BinaryExpr"
  def initialize(node)
    super(node)
    @left = UastNode.uast_node_from_rtree(@node[1])
    @op  = ruby_op_name(@node[2])
    @right  = UastNode.uast_node_from_rtree(@node[3])
  end
end

class AssignmentNode < UastNode
  UAST_NODE_NAME = "Assignment"
  def initialize(node)
    super(node)
    @variable = UastNode.uast_node_from_rtree(@node[1])
    @value = UastNode.uast_node_from_rtree(@node[2])
  end
end

# class VarRefNode < UastNode
#   def initialize(node)
#     super(node)
#     @name = 
#   end
# end

class IntLitNode < UastNode  
  UAST_NODE_NAME = "IntLit"
  def initialize(node)
    super(node)
    @value = @node[1]
  end
end

class DefineNode < UastNode
  def initialize(node)
    super(node)
  end
end

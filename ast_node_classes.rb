# Copyright © Entologic
#
# Ruby uni-ast-gen
#
# OLD custom OO ripper representation

def ruby_op_name(op_sym)
  case op_sym
  when :+ then "Add"
  when :- then "Subtract"
  when :* then "Multiply"
  when :/ then "Divide"
  end
end

class UastNode
  attr_reader :child_nodes

  def initialize(node)
    @node = node
    @loc  = node.last if node[0][0] == "@"
  end

  def self.uast_node_from_rtree(rnode)
    uast_node = case rnode[0]
      when :binary then BinaryNode.new(rnode)
      when :def    then DefineNode.new(rnode)
      when :assign then AssignmentNode.new(rnode)
      when :@int   then IntLitNode.new(rnode)
      else UnknowenNode.new(rnode)
    end
  end
end

class UnknowenNode < UastNode
  def initialize(node)
    super(node)
  end
end

class BinaryNode < UastNode
  def initialize(node)
    super(node)
    @first_arg = UastNode.uast_node_from_rtree(@node[1])
    @operator  = ruby_op_name(@node[2])
    @last_arg  = UastNode.uast_node_from_rtree(@node[3])
  end
end

class AssignmentNode < UastNode
  def initialize(node)
    super(node)
    @var_name = @node
  end
end

class VarRefNode < UastNode
  def initialize(node)
    super(node)
    @name = 
  end
end

class IntLitNode < UastNode
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

# Copyright © Entologic
#
# Ruby uni-ast-gen

def ruby_op_name(op_sym)
  case opsym
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
  end

  def self.uast_node_from_rtree(rnode)
    uast_node = case rnode[0]
    when :binary then BinaryNode.new(rnode)
    when :def    then DefineNode.new(rnode)
    else nil
    end
  end
end

class BinaryNode < UastNode
  def initialize(node)
    super(node)
    @first_arg, @operator, @second_arg = @node[1,3]
  end
end

class DefineNode < UastNode
  def initialize(node)
    super(node)
  end
end

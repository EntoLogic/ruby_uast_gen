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

def statements_list(slist)
  slist.map do |stmt|
    UastNode.uast_node_from_rtree(stmt)
  end
end

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

def remove_if_parens(node)
  return remove_if_parens(node[1]) if node[0] == :paren
  node
end

def param_node_to_strings(params_node)
  # Params may be written with or without parens in ruby, i.e.
  # [:params, nil, nil] or [:paren, [:params, nil, nil]] so
  if params_node[1]
    params_node[1].map do |p_n|
      return nil unless p_n
      p_n[1] if p_n[0] == :@ident
    end.compact
  else
    []
  end
end

class UastNode
  attr_reader :child_nodes

  def initialize(node)
    @node = node

    # Loc seems to only be in @-sign ones
    @loc = {start: node.last} if node[0][0] == "@"
    # offset line location by -1 to comply with UAST
    @loc[:start][0] -= 1 if @loc && @loc[:start].is_a?(Array)
  end

  def self.uast_node_from_rtree(rnode)
    case rnode[0]
      when :binary    then BinaryNode.new(rnode)
      when :def       then DefineMethodNode.new(rnode)
      when :assign    then AssignmentNode.new(rnode)
      when :var_field then var_field_str(rnode)
      when :void_stmt then nil

      # @-sign ones (I think they are for literals)
      when :@int      then IntLitNode.new(rnode)

      # Unknown
      else UnknownNode.new(rnode)
    end
  end

  def to_hash
    hash = {}
    instance_variables.map {|var| hash[var.to_s.delete("@")] = instance_variable_get(var) }
    hash
  end
end

class UnknownNode < UastNode
  UAST_NODE_NAME = "Unknown"
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

class DefineMethodNode < UastNode
  UAST_NODE_NAME = "FuncDecl"
  def initialize(node)
    super(node)
    @name = node[1][1] # :@ident, "hello", [line, col]
    @arguments = param_node_to_strings(remove_if_parens(node[2]))
    stmt_list = statements_list(node[3][1]).compact
    @body = stmt_list.any? ? stmt_list : []
  end
end

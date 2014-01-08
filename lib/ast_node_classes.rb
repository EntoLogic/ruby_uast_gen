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

# def binary_op_name(op_sym)
#   case op_sym
#     when :+ then "add"
#     when :- then "subtract"
#     when :* then "multiply"
#     when :/ then "divide"
#   end
# end

# def comparison_op_name(op_sym)
#   case op_sym
#     when :> then "greaterThan"
#     when :< then "lessThan"
#     when :>= then "greaterOrEqual"
#     when :<= then "lessOrEqual"
#     when :== then "equalTo"
#     when :!= then "notEqual"
#   end
# end

# def var_field_str(vf)
#   vf[1][1]
# end

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

require_relative 'uast_module'

class UastNode
  attr_reader :child_nodes

  include UAST

  def initialize(node)
    @node = node

    # Loc seems to only be in @-sign ones, overrided by some uast nodes
    addLocationArray(node.last) if node[0][0] == "@"
  end

  def addLocationArray(loc)
    @loc = {start: loc}
    # offset line location by -1 to comply with UAST
    @loc[:start][0] -= 1 if @loc && @loc[:start].is_a?(Array)
  end

  def self.uast_node_from_rtree(rnode)
    case rnode[0]
      when :paren              then uast_node_from_rtree(rnode[1][0])
      when :binary             then expression_type(rnode)

      when :def                then DefineMethodNode.new(rnode)
      when :method_add_arg     then FunctionCallNode.new(rnode)
      when :command            then FunctionCallNode.new(rnode)

      when :assign             then AssignmentNode.new(rnode)
      when :var_ref            then VarAccessNode.new(rnode)
      when :var_field          then VarAccessNode.new(rnode)
      when :vcall              then VarAccessNode.new(rnode)

      when :void_stmt          then nil

      # @-sign ones (I think they are for literals)
      when :@int               then IntLitNode.new(rnode)
      when :string_literal     then StringLitNode.new(rnode)

      when :array              then ArrayLitNode.new(rnode)

      # Unknown
      else UnknownNode.new(rnode)
    end
  end

  def self.expression_type(rnode)
    op_string = rnode[2].to_s
    if UAST::BINARY_OPS.has_key?(op_string)
      BinaryNode.new(rnode, op_string)
    elsif UAST::COMPARISON_OPS.has_key?(op_string)
      ComparisonNode.new(rnode, op_string)
    else
      UnknownNode.new(rnode)
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
  def initialize(node, op_str)
    super(node)
    @left = UastNode.uast_node_from_rtree(@node[1])
    @op = UAST::BINARY_OPS[op_str]
    @right  = UastNode.uast_node_from_rtree(@node[3])
  end
end

class ComparisonNode < UastNode
  UAST_NODE_NAME = "ComparisonExpr"
  def initialize(node, op_string)
    super(node)
    @left = UastNode.uast_node_from_rtree(@node[1])
    @op = UAST::COMPARISON_OPS[op_string]
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
    addLocationArray(node[1].last)
  end
end

class VarAccessNode < UastNode
  UAST_NODE_NAME = "VarAccess"
  def initialize(node)
    super(node)
    addLocationArray(node[1].last)
    @var = node[1][1]
  end
end

class FunctionCallNode < UastNode
  UAST_NODE_NAME = "FunctionCall"
  def initialize(node)
    super(node)
    if node[1][0] == :fcall
      @name = node[1][1][1]
      addLocationArray(node[1][1].last)
    elsif node[1][0] == :@ident
      @name = node[1][1]
      addLocationArray(node[1].last)
    end
    args_node = node[2]
    args_block_node = args_node[0] == :arg_paren ? args_node[1] : args_node

    @args = (args_block_node && args_block_node[1].map { |a| UastNode.uast_node_from_rtree(a) }) || []
  end
end

class StringLitNode < UastNode
  UAST_NODE_NAME = "StringLit"
  def initialize(node)
    super(node)
    if node[1][0] == :string_content && node[1][1][0] == :@tstring_content
      @value = node[1][1][1]
      addLocationArray(node[1][1].last)
    end
  end
end

class ArrayLitNode < UastNode
  UAST_NODE_NAME = "ArrayLit"
  def initialize(node)
    super(node)
    @contents = statements_list(node[1])
  end

end
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

def handle_node_object(node_object)
  main_part = transform_hash(node_object.to_hash) do |hash, attr_name, attr_value|
    # NESTED OBJECTS
    if (%w(left right).include?(attr_name)) && (attr_value.is_a? UastNode)
      hash[attr_name] = handle_node_object(attr_value)
    # elsif attr_value.class == Array && attr_attr_value[0]

    # PLAIN STRING ATTRIBUTES
    elsif %w(op variable).include?(attr_name)
      hash[attr_name] = attr_value

    # LOCATION ARRAY
    elsif attr_name == "loc"
      hash["loc"] = attr_value

    # EITHER LITERAL OR NESTED OBJECT
    elsif %w(value).include?(attr_name)
      if (attr_value.is_a? String) || (attr_value.is_a? Integer)
        hash[attr_name] = attr_value.to_s
      elsif attr_value.class <= UastNode
        hash[attr_name] = handle_node_object(attr_value)
      end
    end
  end
  { "node" => node_object.class::UAST_NODE_NAME }.merge(main_part)
end

def handle_array_of_nodes(node_array)
  node_array.map do |nd|
    handle_node_object(nd)
  end
end
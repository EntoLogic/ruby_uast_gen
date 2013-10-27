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
  main_part = transform_hash(node_object.to_hash) do |hash, key, value|
    # NESTED OBJECTS
    if (%w(left right).include?(key)) && (value.class <= UastNode)
      puts "UAST OBJECT"
      hash[key] = handle_node_object(value)
    # elsif attribute_value.class == Array && attribute_value[0]

    # PLAIN STRING ATTRIBUTES
    elsif %w(op value).include?(key)
      hash[key] = value
      puts "STRING"
    # LOCATION ARRAY
    elsif key == "loc"
      hash["loc"] = value
      puts "LOC"
    end
  end
  { "node" => node_object.class::UAST_NODE_NAME }.merge(main_part)
end

def handle_array_of_nodes(node_array)
  node_array.map do |nd|
    handle_node_object(nd)
  end
end
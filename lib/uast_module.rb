module UAST
	BINARY_OPS = {
    "+"    => "add", 
    "-"    => "subtract",
    "*"    => "multiply",
    "/"    => "divide",
    "%"    => "modulo",
    "&&"   => "logicalAnd",
    "||"   => "logicalOr",
    "&"    => "bitAnd",
    "|"    => "bitOr",
    "^"    => "xor",
    ">>"   => "rshift",
    "<<"   => "lshift"
  }

  COMPARISON_OPS = {
    ">" =>   "greaterThan",
    "<" =>   "lessThan",
    ">=" =>  "greaterOrEqual",
    "<=" =>  "lessOrEqual",
    "==" =>  "equalTo",
    "!=" =>  "notEqual"
  }
end
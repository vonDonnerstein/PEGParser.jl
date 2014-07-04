using EBNF
using PEGParser

# for testing purposes
# using DataFrames

@grammar csv begin
  start = data
  data = list(record, crlf)
  record = list(field, comma)
  field = escaped_field | unescaped_field
  escaped_field = dquote + (r"[ ,\n\r!#$%&'()*+\-./0-~]+" | dquote2) + dquote
  unescaped_field = r"[ !#$%&'()*+\-./0-~]+"
  crlf = r"[\n\r]+"
  dquote = '"'
  dqoute2 = "\"\""
  comma = ','
end


toarrays(node::Node, cvalues, ::MatchRule{:default}) = cvalues
toarrays(node::Node, cvalues, ::MatchRule{:escaped_field}) = node.value
toarrays(node::Node, cvalues, ::MatchRule{:unescaped_field}) = node.value
toarrays(node::Node, cvalues, ::MatchRule{:textdata}) = node.value

data = """
1,2,3
4,5,6
this,is,a,"test"
"""

(ast, pos, error) = parse(csv, data)
println(ast)
result = transform(toarrays, ast, ignore=[:dquote, :dquote2, :comma, :crlf])
println(result)

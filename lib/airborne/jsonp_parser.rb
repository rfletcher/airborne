require 'rkelly'

class RKelly::Nodes::PropertyNode
  attr_writer :name
end

module Airborne
  class InvalidJavascriptError < StandardError; end
  class UnsupportedJsonpError < StandardError; end

  module JsonpParser
    def jsonp_body
      begin
        ast = RKelly::Parser.new.parse(body)
      rescue
        fail InvalidJavascriptError, 'API request returned invalid javascript'
      end

      jsonp = {}
      json_safe_string = lambda { |s| s.gsub( /(?:(['"])|\1$)/, '' ).to_json }

      function_call_nodes = ast.select { |node|
        node.is_a?( RKelly::Nodes::FunctionCallNode )
      }

      if function_call_nodes.size != 1
        fail UnsupportedJsonpError, 'Expected 1 JSONP callback, found #{function_call_nodes.size}.'
      end

      function_call_node = function_call_nodes.first
      function_name_node = function_call_node.value.first

      unless function_name_node.is_a?(RKelly::Nodes::ResolveNode)
        fail UnsupportedJsonpError, 'Simple "callback(arg, ...)" is supported. Found something else.'
      end

      args_node = function_call_node.find { |node|
        node.is_a?( RKelly::Nodes::ArgumentsNode )
      }

      # convert JS callback arguments into a JSON-safe array of values
      args_node.each { |node|
        if node.is_a?( RKelly::Nodes::PropertyNode )
          node.name = json_safe_string.call( node.name )
        elsif node.is_a?( RKelly::Nodes::StringNode )
          node.value = json_safe_string.call( node.value )
        end
      }
      args_array = RKelly::Nodes::ArrayNode.new( args_node.value )

      function_name = function_name_node.value
      preamble = body[0, body.index(function_name)]

      {
        :method    => function_name.to_sym,
        :preamble  => preamble == "" ? nil : preamble,
        :arguments => JSON.parse(args_array.to_ecma, symbolize_names: true)
      }
    end
  end
end

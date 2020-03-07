require "http"
require "radix"

# TODO: Write documentation for `Kitsune`
module Kitsune
  VERSION = {{`shards version #{__DIR__}/..`.strip.stringify}}

  module App(ContextType)
    include HTTP::Handler

    def initialize(@prefix : String = "/")
      {% raise "App's ContextType must be a Kitsune::Context" unless ContextType <= Kitsune::Context %}
      routes
    end

    # Called on setup to setup routes
    abstract def routes

    @routes = Radix::Tree(ContextType ->).new

    def call(context : HTTP::Server::Context)
      route = Path.posix(context.request.method.upcase, context.request.path).to_s
      result = @routes.find(route)

      if handler = result.payload?
        context = ContextType.new(context, result.params)
        handler.call(context)
      else
        call_next(context)
      end
    end

    def route(method : String, path : String, block : ContextType -> _)
      unless method.each_char.all? { |char| Kitsune.is_tchar?(char) }
        raise InvalidRouteException.new(
          "Invalid method #{method.inspect}: HTTP methods must contain only tchars (RFC7230 3.2.6)"
        )
      end

      route = Path.posix(method.upcase, @prefix, path).to_s

      @routes.add route, block
    end

    def route(method : String, path : String, &block : ContextType -> _)
      route(method, path, block)
    end

    {% for method in %w(get post put head delete patch options) %}
      def {{method.id}}(path : String, block : ContextType -> _)
        route({{method}}, path, block)
      end

      def {{method.id}}(path : String, &block : ContextType -> _)
        route({{method}}, path, block)
      end
    {% end %}

    def listen(host = "localhost", port = 8088)
      server = HTTP::Server.new(self)
      puts "Kitsune listening on http://#{host}:#{port}"
      server.listen(host, port)
    end
  end

  class InvalidRouteException < Exception
  end

  class Context < HTTP::Server::Context
    getter url_params : Hash(String, String)

    def initialize(context : HTTP::Server::Context, url_params : Hash(String, String))
      @request = context.request
      @response = context.response
      @url_params = url_params
    end
  end

  protected def self.is_tchar?(char : Char)
    char.ascii_alphanumeric? || char.in?('!', '#', '$', '%', '&', '\'', '*', '+', '-', '.', '^', '_', '`', '|', '~')
  end
end

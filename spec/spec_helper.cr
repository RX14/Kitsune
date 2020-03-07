require "spec"
require "../src/kitsune"

class TestApp
  include Kitsune::App(Kitsune::Context)

  def routes
  end
end

module Kitsune::App(ContextType)
  def request(*args) : HTTP::Client::Response
    request_io = IO::Memory.new
    response_io = IO::Memory.new

    request = HTTP::Request.new(*args)
    request.to_io(request_io)
    request_io.rewind

    HTTP::Server::RequestProcessor.new(self).process(request_io, response_io)
    response_io.rewind

    HTTP::Client::Response.from_io(response_io)
  end
end

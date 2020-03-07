require "./spec_helper"

describe Kitsune do
  it "routes requests" do
    app = TestApp.new
    app.get "/" { |ctx| ctx.response << "Root" }
    app.post "/" { |ctx| ctx.response << "POST" }
    app.get "/foo" { |ctx| ctx.response << "foo" }

    response = app.request("GET", "/")
    response.status_code.should eq(200)
    response.body.should eq("Root")

    response = app.request("post", "/")
    response.status_code.should eq(200)
    response.body.should eq("POST")

    response = app.request("put", "/")
    response.status_code.should eq(404)

    response = app.request("GET", "/foo")
    response.status_code.should eq(200)
    response.body.should eq("foo")

    response = app.request("GET", "/bar")
    response.status_code.should eq(404)
  end

  it "exposes URL params" do
    app = TestApp.new
    app.get "/" { |ctx| ctx.response << "Root" }
    app.get "/:name" { |ctx| ctx.response << ctx.url_params["name"] }
    app.get "/foo/:foo" { |ctx| ctx.response << "foo|" << ctx.url_params["foo"] }

    response = app.request("GET", "/")
    response.status_code.should eq(200)
    response.body.should eq("Root")

    response = app.request("GET", "/bar")
    response.status_code.should eq(200)
    response.body.should eq("bar")

    response = app.request("GET", "/foo/bar")
    response.status_code.should eq(200)
    response.body.should eq("foo|bar")
  end

  it "routes on a prefix" do
    {"prefix", "/prefix", "/prefix/"}.each do |prefix|
      app = TestApp.new(prefix)
      app.get "/" { |ctx| ctx.response << "Root" }
      app.get "/foo" { |ctx| ctx.response << "foo" }

      response = app.request("GET", "/")
      response.status_code.should eq(404)

      response = app.request("GET", "/prefix/")
      response.status_code.should eq(200)

      # FIXME: https://github.com/luislavena/radix/issues/27
      # response = app.request("GET", "/foo")
      # response.status_code.should eq(404)

      response = app.request("GET", "/prefix/foo")
      response.status_code.should eq(200)
    end
  end

  it "disallows invalid methods in routes" do
    app = TestApp.new
    expect_raises(Kitsune::InvalidRouteException, %(Invalid method "GET/")) do
      app.route("GET/", "/") { }
    end
  end
end

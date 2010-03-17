require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

Gateway = Twitter::Sinefunc::Gateway

describe Gateway do
  it "should require an access_token and an access_secret" do
    lambda {
      Twitter::Sinefunc::Gateway.new
    }.should raise_error(ArgumentError, /token and secret/)
  end
end

describe Gateway, "doing a GET /statuses" do
  before( :each ) do
    @gateway = Gateway.new token: "my token", secret: "my secret"
  end  

  it "should call get http://twitter.com/statuses.json" do
    FakeWeb.register_uri(:get, "http://twitter.com/statuses.json",
                         :body => { "id" => 123456 }.to_json)

    @gateway.get "/statuses"
  end

  it "should return the parsed JSON" do 
    FakeWeb.register_uri(:get, "http://twitter.com/statuses.json",
                         :body => { "id" => 123456 }.to_json)

    @gateway.get("/statuses").should == { "id" => 123456 }
  end
  
  context "when the response body is not JSON parseable" do
    it "should return the actual response body" do
      FakeWeb.register_uri(:get, "http://twitter.com/statuses.json",
                           :body => "this is not json parseable")

      @gateway.get("/statuses").should == "this is not json parseable"
    end
  end

  context "when the credentials does not authorize the user" do
    it do
      FakeWeb.register_uri(:get, "http://twitter.com/statuses.json",
                           :body => "bla", :status => [ 401, "Unauthorized" ])

      lambda {
        @gateway.get("/statuses")
      }.should raise_error(Gateway::Unauthorized)
    end
  end

  context "when the response is a json error" do
    it do
      FakeWeb.register_uri(:get, "http://twitter.com/statuses.json",
                           :body => { "error" => "FooBar" }.to_json,
                           :status => [ 406, "Unprocessable Entity" ])

      lambda {
        @gateway.get("/statuses")
      }.should raise_error(Gateway::Error, "FooBar")
    end
  end

  context "when the response is an XML error" do
    it do
      FakeWeb.register_uri(:get, "http://twitter.com/statuses.json",
                           :body => "<error>FooBar</error>",
                           :status => [ 406, "Unprocessable Entity" ])

      lambda {
        @gateway.get("/statuses")
      }.should raise_error(Gateway::Error, "FooBar")
    end
  end

  context "when the response is just an error without the proper error" do
    it do
      FakeWeb.register_uri(:get, "http://twitter.com/statuses.json",
                           :body => "FooBar",
                           :status => [ 406, "Unprocessable Entity" ])

      lambda {
        @gateway.get("/statuses")
      }.should raise_error(Gateway::Error, /error/)
    end
  end
end

require File.dirname(__FILE__)+'/../../spec_helper'

describe Gom::Remote::HttpServer do

  describe "initialization" do
    it "should not be running on creation" do
      server = Gom::Remote::HttpServer.new
      server.running?.should == false
    end
  end

  it "should overwrite host option" do
    @server = Gom::Remote::HttpServer.new :host => "1.2.3.4"
    @server.host.should == "1.2.3.4"
  end

  it "should overwrite port option" do
    @server = Gom::Remote::HttpServer.new :port => 9151
    @server.port.should == 9151
  end

  describe "with a server" do
    before :each do
      @server = Gom::Remote::HttpServer.new
    end

    it "should match empty mounts to nil" do
      @server.send(:match, (URI.parse '/foo/aa;bb;cc?p1=12&p2=oo')).should == nil
    end

    it "should not missmatch" do
      @server.mount '^/a',     lambda { }
      @server.mount '^/a/b',   lambda { }
      @server.mount '^/a/b/c', lambda { }
      @server.match(URI.parse '/x/a/b/c').should == nil
      @server.match(URI.parse '/x/a/b').should == nil
      @server.match(URI.parse '/x/a').should == nil
      @server.match(URI.parse 'a').should == nil
    end

    it "should unmount" do
      @server.mount '/a/b/c', (l = lambda { "block 6" })
      @server.match(URI.parse '/a/b/c/d').should == l
      @server.unmount '/a/b/c'
      @server.match(URI.parse '/a/b/c/d').should == nil
    end

    it "should match with regexp as well" do
      @server.mount %r{/a},     (l1 = lambda { "block 1" })
      @server.mount %r{/a/b},   (l2 = lambda { "block 2" })
      @server.mount %r{/a/b/c}, (l3 = lambda { "block 3" })
      @server.match(URI.parse '/a/b').should == l2
      @server.match(URI.parse '/a/b/c').should == l3
      @server.match(URI.parse '/a/b/x').should == l2
      @server.match(URI.parse '/a/b/c/d').should == l3
    end

    it "should prefer longer matches" do
      @server.mount '/a',     (l1 = lambda { "block 1" })
      @server.mount '/a/b',   (l2 = lambda { "block 2" })
      @server.mount '/a/b/c', (l3 = lambda { "block 3" })
      @server.match(URI.parse '/a/b').should == l2
      @server.match(URI.parse '/a/b/c').should == l3
      @server.match(URI.parse '/a/b/x').should == l2
      @server.match(URI.parse '/a/b/c/d').should == l3
    end

    it "should match simple strings" do
      @server.mount "/foo", (l = lambda { puts "needs some code here" })
      @server.match(URI.parse '/foo/aa;bb;cc?p1=12&p2=oo').should == l
    end

    it "should have default mongrel options" do
      @server.port.should == Gom::Remote::HttpServer::Defaults[:port]
      @server.host.should == Gom::Remote::HttpServer::Defaults[:host]
    end

    #it "should dispatch a nagios callback" do
    #  @cs.should_not_receive(:gnp_dispatcher)
    #  response = @cs.send(:dispatch_request_uri, "/nagios;foo;bar", {}) 
    #  response.should == [200, {"Content-Type"=>"text/plain"}, ["OK"]]
    #end

    it "should start and stop" do
      @server.start.class.should == Thread
      #sleep 1
      @server.running?.should == true
      @server.stop.should == @server
      sleep 1
      @server.running?.should == false
    end
  end
end

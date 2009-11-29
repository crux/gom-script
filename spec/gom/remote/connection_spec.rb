require File.dirname(__FILE__)+'/../../spec_helper'

describe Gom::Remote::Connection do

  describe "initialization" do
    it "should split a GOM node url" do
      gom, path = (Gom::Remote::Connection.split_url 'http://gom:345/dmx/node')
      gom.should == 'http://gom:345'
      path.should == '/dmx/node'
    end
    it "should strip last slash from the node" do
      gom, path = (Gom::Remote::Connection.split_url 'http://xxx:4321/a/b/c/')
      gom.should == 'http://xxx:4321'
      path.should == '/a/b/c'
      gom, path = (Gom::Remote::Connection.split_url 'http://xxx:4321/a/b:c/')
      gom.should == 'http://xxx:4321'
      path.should == '/a/b:c'
    end
    it "should split an attribute URL" do
      gom, path = (Gom::Remote::Connection.split_url 'http://xxx/a:x')
      gom.should == 'http://xxx'
      path.should == '/a:x'
    end
    it "should split a GOM node url on init" do
      gom, path = (Gom::Remote::Connection.init 'http://gom:345/dmx/node')
      gom.target_url.should == 'http://gom:345'
      path.should == '/dmx/node'
    end
  end

  describe "with a connection it" do
    before :each do
      @gom, path = (Gom::Remote::Connection.init 'http://gom:345/dmx/node')
    end

    it "should fetch the callback_ip from remote" do
      @gom.callback_server.host.should == "10.0.0.23"
    end

    it "should put attribute values to remote" do
      @gom.should_receive(:http_put).
        with("http://gom:345/some/node:attr", { "attribute" => "abc", "type" => :string })
      @gom.write '/some/node:attr', "abc"
    end
  end

  describe "with subscriptions" do 
    before :each do
      @gom, path = (Gom::Remote::Connection.init 'http://localhost:3000')
      @gom.stub!(:run_callback_server).and_return(true)
    end

    #it "should have no subscriptions on init" do
    #  @gom.subscriptions.should == []
    #end

    it "should subscribe operations whitelist" do
      s = (Gom::Remote::Subscription.new '/node', :operations => [:delete, :create])
      @gom.should_receive(:http_put).with(
        "http://localhost:3000/gom/observer/node/.#{s.name}", 
        hash_including("attributes[operations]" => 'delete, create')
      )
      @gom.subscribe s
      @gom.refresh
    end

    it "should have an uri regexp" do
      s = (Gom::Remote::Subscription.new '/node', :uri_regexp => /foo/)
      @gom.should_receive(:http_put).with(
        "http://localhost:3000/gom/observer/node/.#{s.name}", 
        hash_including("attributes[uri_regexp]" => /foo/)
      )
      @gom.subscribe s
      @gom.refresh
    end

    it "should have accept=application/json param" do
      s = (Gom::Remote::Subscription.new '/node')
      @gom.should_receive(:http_put).with(
        "http://localhost:3000/gom/observer/node/.#{s.name}", 
        hash_including("attributes[accept]" => 'application/json')
      )
      @gom.subscribe s
      @gom.refresh
    end

    it "should put observer to gom on refresh" do
      s = (Gom::Remote::Subscription.new '/node/values')
      @gom.should_receive(:http_put).with(
        "http://localhost:3000/gom/observer/node/values/.#{s.name}", 
        #hash_including("attributes[callback_url]" => "http://1.2.3.4:2179/gnp;#{s.name};/node/values") 
        hash_including("attributes[callback_url]" => anything)
      )
      @gom.subscribe s
      @gom.refresh
    end

    it "should observe an attribute entry" do
      s = (Gom::Remote::Subscription.new '/node:attribute')
      @gom.should_receive(:http_put).with(
        "http://localhost:3000/gom/observer/node/attribute/.#{s.name}", 
        #hash_including("attributes[callback_url]" => "http://1.2.3.4:2179/gnp;#{s.name};/node:attribute") 
        hash_including("attributes[callback_url]" => anything)
      )
      @gom.subscribe s
      @gom.refresh
    end
  end
end

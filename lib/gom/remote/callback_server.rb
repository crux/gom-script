require 'rack'
require 'rack/handler/mongrel'

module Gom
  module Remote
    class CallbackServer
      Defaults = {
        :Host => "0.0.0.0", :Port => 2719, 
      }

      def host
        @options[:Host]
      end
      def port
        @options[:Port]
      end

      def initialize options = {}, &handler
        @options = (Defaults.merge options)
        (@handler = handler) or (raise "no callback handler!")
      end

      def running?
        !@server.nil?
      end

      def start &handler
        @server.nil? or (raise "already running!")
        @thread = Thread.new do
          puts " -- starting callback server"
          begin
            f = Proc.new {|env| dispatch env}
            Rack::Handler::Mongrel.run(f, @options) do |server|
              puts "    mongrel up: #{server}"
              @server = server
            end
          rescue Exception => e
            puts " ## oops: #{e}"
            puts @options.inspect
          end
        end
        self
      end

      def stop
        @server.nil? and (raise "not running!")
        puts ' -- stopping callback server..'
        @server.stop
        @server = nil
        puts '    down.'
        sleep 2 # sleep added as a precaution
        puts ' -- killing callback thread now...'
        @thread.kill
        @thread = nil
        puts '    and gone.'
        self
      end

      private

      def dispatch env
        #puts("-" * 80)
        #puts env.inspect
        #puts("-" * 80)
        req = Rack::Request.new(env)
        #params = req.params

        #debugger if (defined? debugger)
        _, name, entry_uri = env['REQUEST_URI'].split(/;/)
        @handler.call(name, entry_uri, req)
        [200, {"Content-Type"=>"text/plain"}, ["keep going dude!"]]

      rescue => e
        puts " ## #{e}\n -> #{e.backtrace.join "\n    "}"
        [500, {"Content-Type"=>"text/plain"}, [e]]
      end
    end
  end
end

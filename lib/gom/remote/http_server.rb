require 'rack'
require 'rack/handler/mongrel'
require 'thread'
require 'applix/oattr'

module Gom
  module Remote
    class HttpServer

      Defaults = {
        :host => "0.0.0.0", :port => 25191
      }

      include OAttr
      oattr :host, :port

      def initialize options = {}
        @options = (Defaults.merge options)
        @mounts = {}
        @mounts_access = Mutex.new
      end

      def running?
        !@server.nil?
      end

      def mount pattern, handler
        @mounts_access.synchronize { @mounts.update pattern => handler }
      end

      def unmount pattern
        @mounts_access.synchronize { @mounts.delete pattern }
      end

      def start
        @server.nil? or (raise "already running!")
        @thread = Thread.new { start_mongrel_server }
        sleep 0.1 # give thread time for start-up
        @thread
      end

      def stop
        @server.nil? and (raise "not running!")
        puts ' -- stopping callback server..'
        @server.stop
        @server = nil
        puts '    down.'
        sleep 2 # sleep added as a precaution 
        puts ' -- killing server thread now...'
        @thread.kill
        @thread = nil
        puts '    and gone.'
        self
      end

      def match uri
        targets = []
        @mounts_access.synchronize do
          targets = @mounts.map do |re, app|
            [app, (uri.path.match re).to_s]
          end
        end
        targets.sort! { |a,b| a[1].length <=> b[1].length }
        targets.last
      end

      private

      # dispatching a request URI from env['REQUEST_URI'] which look
      # somethings like: 
      # 
      #   http://172.20.2.9:2719/gnp;enttec-dmx;/services/enttec-dmx-usb-pro/values
      #
      def dispatch env
        #puts("-" * 80)
        #puts env.inspect
        #puts("-" * 80)
        req = Rack::Request.new(env)
        #params = req.params
        debugger if(defined? debugger)
        body = ["#{(env.map { |k,v| "#{k}: #{v}" }.join "\n")}"]
        body.push "\n"
        body.push "request url: #{req.url}\n"
        body.push "request fullpath: #{req.fullpath}\n"
        uri = (URI.parse req.fullpath)
        return [200, {"Content-Type"=>"text/plain"}, body]

        request_uri = env['REQUEST_URI']
        op, name, entry_uri = (request_uri.split /;/)
        case op[1..-1].to_sym
        when :gnp
          gnp_dispatcher name, entry_uri, Rack::Request.new(env)
        when :nagios
          [200, {"Content-Type"=>"text/plain"}, ["OK"]]
        else
          puts "#{self}: unsupported callback op: '#{op}' -- #{request_uri}"
          [404, {"Content-Type"=>"text/plain"}, ["Not Found"]]
        end
      rescue => e
        puts " ## #{e}\n -> #{e.backtrace.join "\n    "}"
        [500, {"Content-Type"=>"text/plain"}, [e]]
      end

      # as i absolutly displike capitalized options i use lowercase options
      # throughout and only convert them just before i pass them the the
      # mongrel server. Nothing to be proud of, but i definitly don't want to
      # write --Port on the command line...
      def mongrel_opts
        @options.merge :Host => @options[:host], :Port => @options[:port]
      end

      def start_mongrel_server
        puts " -- starting http server: #{@options.inspect}"
        @server.nil? or (raise "already running!")
        f = Proc.new {|env| dispatch env}
        Rack::Handler::Mongrel.run(f, mongrel_opts) do |server|
          @server = server
          puts "    mongrel up: #{server.inspect}"
        end
      rescue Exception => e
        puts " ## oops: #{e}"
        puts @options.inspect
      end
    end
  end
end

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

      def base_url
        p = (port == 80 ? '' : ":#{port}")
        "http://#{host}#{p}"
      end

      def running?
        !@server.nil?
      end

      def mount pattern, handler
        @mounts_access.synchronize { @mounts.update pattern => handler }
        self
      end

      def unmount pattern
        @mounts_access.synchronize { @mounts.delete pattern }
        self
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

      # take the URI on walk it through the list of mounts and return the one
      # with the longest match or nil. In case of a match the corresponding
      # handler is returned, nil otherwise.
      def match uri
        targets = []
        @mounts_access.synchronize do
          targets = @mounts.map do |re, app|
            [app, (uri.path.match re).to_s]
          end
        end

        # sort for longest match. And target might be nil already for an empty
        # targets list, which is ok as we return nil in that case.
        target = targets.sort!{|a,b| a[1].length <=> b[1].length}.last
        func, pattern = target
        (pattern.nil? || pattern.empty?) ? nil : func
      end

      private

      # dispatching a request URI from env['REQUEST_URI'] which look
      # somethings like: 
      # 
      #   http://172.20.2.9:2719/gnp;enttec-dmx;/services/enttec-dmx-usb-pro/values
      #
      def dispatch env
        #req = Rack::Request.new(env)
        uri = (URI.parse env['REQUEST_URI'])
        if func = (match uri)
          func.call uri, env
        else
          puts " !! no handler for: #{req.fullpath} -- #{@mounts.keys.inspect}"
          [404, {"Content-Type"=>"text/plain"}, ["Not Found"]]
        end
      rescue => e
        puts " ## #{e}\n -> #{e.backtrace.join "\n    "}"
        [500, {"Content-Type"=>"text/plain"}, [e]]
      end

      # as i absolutly dislike capitalized options i use lowercase options
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
          puts "    mongrel up: #{@options.inspect}"
        end
      rescue Exception => e
        puts " ## oops: #{e}"
        puts @options.inspect
      end
    end
  end
end

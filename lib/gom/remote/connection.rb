require 'net/http'
require 'open-uri'
require 'json'

module Gom
  module Remote

    class << self; attr_accessor :connection; end

    class Connection

      attr_reader :target_url, :initial_path, :callback_server

      class << self
        # take apart the URL into GOM and node path part
        def split_url url
          u = URI.parse url
          re = %r|#{u.scheme}://#{u.host}(:#{u.port})?|
            server = (re.match url).to_s
          path = (url.sub server, '').sub(/\/$/, '')
          [server, path]
        end

        def init url, callback_port = nil
          connection = (self.new url, callback_port)
          [connection, connection.initial_path]
        end
      end

      # url: initial GOM url, path or attribute. The remote GOM server
      # address gets extracted from this and, unless nil, the given block
      # will be called with the remaining GOM path, aka:
      #
      #   url == http://gom:1234/foo/bar:attribute 
      #
      # will use 'http://gom:1234' as GOM server and call the block with
      # '/foo/bar:attribute' as path argument.
      #
      def initialize url, callback_port = nil
        @target_url, @initial_path = (Connection.split_url url)
        #Gom::Remote.connection and (raise "connection already open")
        Gom::Remote.connection = self

        @subscriptions = []
        @callback_server = init_callback_server callback_port
      end

      def write path, value
        if value.kind_of? Hash 
          write_node path, attributes
        else
          write_attribute path, value
        end
      end

      def write_attribute path, value
        # TODO: Primitive#encode returns to_s for all unknow types. exception
        # would be correct.
        txt, type = (Gom::Core::Primitive.encode value)
        params = { "attribute" => txt, "type" => type }
        url = "#{@target_url}#{path}"
        http_put(url, params)
      end
      
      def write_node path, attributes
        raise "not yet implemented"
      end

      def read path
        url = "#{@target_url}#{path}"
        open(url).read
      rescue Timeout::Error => e
        raise "connection timeout: #{url}"
      rescue OpenURI::HTTPError => e
        case code = e.to_s.to_i rescue 0
        when 404
          raise NameError, "undefined: #{path}"
        else
          puts " ## gom connection error: #{url} -- #{e}"
          throw e
        end
      rescue => e
        puts " ## read error: #{url} -- #{e}"
        throw e
      end

      # update subscription observers. GNP callbacks will look like:
      # 
      #   http://<callback server>:<callback port>/gnp;<subscription name>;<subscription path>
      #
      def refresh
        puts " -- refresh subscriptions(#{@subscriptions.size}):"

        run_callback_server # call it once to make sure it runs
        
        @subscriptions.each do |sub| 
          puts "     - #{sub.name}"
          params = { "attributes[accept]" => 'application/json' }

          query = "/gnp;#{sub.name};#{sub.entry_uri}"
          params["attributes[callback_url]"] = "#{callback_server.base_url}#{query}"

          [:operations, :uri_regexp, :condition_script].each do |key|
            (v = sub.send key) and params["attributes[#{key}]"] = v
          end

          url = "#{@target_url}#{sub.uri}"
          http_put(url, params) # {|req| req.content_type = 'application/json'}
        end
      end

      def subscribe sub
        @subscriptions.delete sub # every sub only once!
        @subscriptions.push sub
      end

      private

      def init_callback_server port
        txt = (read "/gom/config/connection.txt")
        unless m = (txt.match /^client_ip:\s*(\d+\.\d+\.\d+\.\d+)/) 
          raise "/gom/config/connection: No Client IP? '#{txt}'"
        end
        # this is the IP by which i am seen from the GOM 
        ip = m[1]

        http = (HttpServer.new :host => ip, :port => port)
        http.mount "^/gnp;", lambda {|*args| gnp_handler *args}

        http
      end

      def run_callback_server
        callback_server.start unless callback_server.running? 
      end

      #def gnp_callback name, entry_uri, req
      def gnp_handler request_uri, env
        op, name, entry_uri = (request_uri.to_s.split /;/)
        unless sub = @subscriptions.find { |s| s.name == name }
          raise "no such subscription: #{name} :: #{entry_uri}"#\n#{@subscriptions.inspect}"
        end

        begin
          req = Rack::Request.new(env)
          op, payload = (decode_gnp_body req.body.read)
          (sub.callback.call op, payload)
        rescue => e
          callstack = "#{e.backtrace.join "\n    "}"
          puts " ## Subscription::callback - #{e}\n -> #{callstack}"
        end 

        # HTTP OK keeps the subscription alive, even in case of handler errors
        [200, {"Content-Type"=>"text/plain"}, ["keep going dude!"]]
      end

      def decode_gnp_body txt
        debugger if (defined? debugger)
        json = (JSON.parse txt)
        puts " -- json GNP: #{json.inspect}"

        payload = nil
        op = %w{update delete create}.find { |op| json[op] }
        %w{attribute node}.find { |t| payload = json[op][t] }
        #puts "payload: #{payload.inspect}"
        [op, payload]

        #op = (json.include? 'update') ? :udpate : nil
        #op ||= (json.include? 'delete') ? :delete : nil
        #op ||= (json.include? 'create') ? :create : nil
        #op or (raise "unknown GNP op: #{txt}") 

        #payload = json[op.to_s]
        #[op, (payload['attribute'] || payload['node'])]
      end

      # incapsulates the underlying net access
      def http_put(url, params, &request_modifier)
        uri = URI.parse url
        req = Net::HTTP::Put.new uri.path
        req.set_form_data(params)
        request_modifier && (request_modifier.call req)

        session = (Net::HTTP.new uri.host, uri.port)
        case res = session.start { |http| http.request req }
        when Net::HTTPSuccess, Net::HTTPRedirection
          # OK
        else
          res.error!
        end
      end
    end
  end
end

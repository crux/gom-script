require 'net/http'
require 'open-uri'
require 'json'

module Gom
  module Remote

    class << self; attr_accessor :connection; end

    class Connection

      attr_reader :base_url

      Defaults = {
        :callback_port => 2719
      }

      # @deprecated 
      # use split_url & new
      def self.init url, options = {}
        server, path = (Connection.split_url url)
        connection= (self.new server, options)
        [connection, path]
      end

      # take apart the URL into GOM and node path part
      def self.split_url url
        u = URI.parse url
        re = %r|#{u.scheme}://#{u.host}(:#{u.port})?|
        server = (re.match url).to_s
        path = (url.sub server, '').sub(/\/$/, '')
        [server, path]
      end

      def initialize base_url, options = {}
        @options = (Defaults.merge options)
        @base_url = base_url
        #Gom::Remote.connection and (raise "connection already open")
        Gom::Remote.connection = self

        @subscriptions = []

        #o = { :Host => callback_ip, :Port => @options[:callback_port] }
        #@callback_server = CallbackServer.new(o) {|*args| gnp_callback *args}
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
        url = "#{@base_url}#{path}"
        http_put(url, params)
      end
      
      def write_node path, attributes
        raise "not yet implemented"
      end

      def read path
        url = "#{@base_url}#{path}"
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
        @subscriptions.each do |sub| 
          puts "     - #{sub.name}"
          params = { "attributes[accept]" => 'application/json' }

          query = "/gnp;#{sub.name};#{sub.entry_uri}"
          params["attributes[callback_url]"] = "#{callback_server_base}#{query}"

          [:operations, :uri_regexp, :condition_script].each do |key|
            (v = sub.send key) and params["attributes[#{key}]"] = v
          end

          url = "#{@base_url}#{sub.uri}"
          http_put(url, params) # {|req| req.content_type = 'application/json'}
        end
      end

      def subscribe sub
        @subscriptions.delete sub # every sub only once!
        @subscriptions.push sub
      end

      def callback_server
        #@callback_server or (raise 'no callback server running!')
        @callback_server ||= start_callback_server
      end

      def callback_ip
        #debugger if (defined? debugger)
        txt = (read "/gom/config/connection.txt")
        unless m = (txt.match /^client_ip:\s*(\d+\.\d+\.\d+\.\d+)/) 
          raise "/gom/config/connection: No Client IP? '#{txt}'"
        end
        @callback_ip = m[1]
      end

      private

      def gnp_callback name, entry_uri, req
        unless sub = @subscriptions.find { |s| s.name == name }
          raise "no such subscription: #{name} :: #{entry_uri}"#\n#{@subscriptions.inspect}"
        end
        op, payload = (decode_gnp_body req.body.read)
        begin
          (sub.callback.call op, payload)
        rescue => e
          callstack = "#{e.backtrace.join "\n    "}"
          puts " ## Subscription::callback - #{e}\n -> #{callstack}"
        end 
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

      def callback_server_base
        "http://#{callback_server.host}:#{callback_server.port}"
      end

      def start_callback_server
        unless @callback_server
          o = { :Host => callback_ip, :Port => @options[:callback_port] }
          @callback_server = CallbackServer.new(o) {|*args| gnp_callback *args}
        end
        @callback_server.start # {|*args| gnp_callback *args}
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

require 'timeout'
module Gom
  module Remote
    class Daemon

      include ::Timeout

      Defaults = { 
        :refresh_interval_dt => 60,
        :callback_port       => 8815,
      }

      def initialize service_url, options = {}, &blk
        @options = (Defaults.merge options)

        callback_port = @options[:callback_port]
        @gom, path = (Connection.init service_url, callback_port)

        (blk.call self, path) unless blk.nil?
      end

=begin
      def open_nagios_port jjjjj
        @gom.callback_server.mount(%r{^/nagios}, lambda do |*args|
          uri, env = *args
          req = Rack::Request.new(env)
          envmap = (env.map { |k,v| "#{k}: #{v}" }.join "\n")
          body = ["OK -- #{env['REQUEST_URI']}\n---\n#{envmap}"]
          [200, {"Content-Type"=>"text/plain"}, body]
        end)
      end
          hs = HttpServer.new o 
          hs.mount "^/gnp;", lambda {|*args| gnp_handler *args}
=end

      def run &tic
        puts " -- running gom script daemon loop..."
        loop do
          begin
            puts "#{Time.now} --"
            @gom.refresh
            tic && (tic.call self)
          rescue Exception => e
            puts " ## #{e}\n -> #{e.backtrace.join "\n    "}"
          ensure
            #IO.fsync
          end
          sleep @options[:refresh_interval_dt]
        end
      end
    end
  end
end

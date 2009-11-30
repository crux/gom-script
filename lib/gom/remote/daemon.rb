require 'timeout'
module Gom
  module Remote
    class Daemon

      include ::Timeout

      Defaults = { 
        :actor_dt       => 60,
        :sensor_dt      => 1,
        :callback_port  => 8815,
      }

      include OAttr
      oattr :actor_dt, :sensor_dt

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
      def sensor_loop interval = sensor_dt, &tic
        puts " -- running gom-script sensor loop.."
        forever(interval) { tic.call self }
      end

      def actor_loop interval = actor_dt, &tic
        puts " -- running gom-script actor loop.."
        forever(interval) do 
          @gom.refresh
          tic && (tic.call self) || :continue
        end
      end

      private

      def forever interval, &callback 
        loop do
          begin
            rc = callback.call
          rescue Exception => e
            puts " ## #{self} - #{e}\n -> #{e.backtrace.join "\n    "}"
          ensure
            break if rc == :stop
            sleep interval
          end
        end
      end
    end
  end
end

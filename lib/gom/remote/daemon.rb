require 'timeout'
module Gom
  module Remote
    class Daemon

      include ::Timeout

      Defaults = { 
        :refresh_interval_dt => 60
      }

      # url: initial GOM url, path or attribute. The remote GOM server address
      # gets extracted from this and, unless nil, the given block will be
      # called with the remaining GOM path, aka:
      #
      #   url == http://gom:1234/foo/bar:attribute 
      #
      # will use 'http://gom:1234' as GOM server and call the block with
      # '/foo/bar:attribute' as path argument.
      #
      def initialize url, options = {}, &blk
        @options = (Defaults.merge options)
        @gom, path = (Gom::Remote::Connection.init url)
        #@dmx = DmxNode.new dmx_node_path, @options
        (blk.call path) unless blk.nil?
      end

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

module Gom
  module Remote
    class Subscription
      
      Defaults = {
        :name             => nil,
        :operations       => [:update],
        :condition_script => nil, 
        :uri_regexp       => nil,
        :callback         => nil, 
      }

      attr_reader :entry_uri, :uri, :callback
      attr_accessor :callback
      attr_reader :name, :operations, :condition_script, :uri_regexp

      def to_s
        "#{self.class}: #{@options.inject}"
      end

      # hint: supplying a recognizable name helps with distributed gom
      # operations 
      #
      def initialize entry_uri, options = {}, &blk
        @name = options[:name] || "0x#{object_id}"
        # URI for the observer node 
        @uri = "/gom/observer#{entry_uri.sub ':', '/'}/.#{@name}"

        @options = Defaults.merge options
        @entry_uri = entry_uri
        @callback = options[:callback] || blk;
        @operations = (@options[:operations] || []).join ', '
        @uri_regexp = (re = @options[:uri_regexp]) && (Regexp.new re) || nil
        @condition_script = @options[:condition_script]
      end
    end
  end
end

module Gom
  module Remote
    class Entry
      include Gom::Remote
      def gom 
        Gom::Remote.connection
      end
      # @deprecated?
      def connection 
        Gom::Remote.connection
      end

      def gnode path
        json = (connection.read "#{path}.json")
        (JSON.parse json)["node"]["entries"].select do |entry|
          # 1. select attribute entries
          entry.has_key? "attribute"
        end.inject({}) do |h, a|
            # 2. make it a key, value list
            h[a["attribute"]["name"].to_sym] = a["attribute"]["value"]
            h
        end
      end
    end
  end
end


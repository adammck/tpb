module TPB
  class Result
    attr_accessor :name, :url, :seeders, :leechers, :magnet_url, :torrent_url

    def initialize(attrs)
      attrs.each do |key, val|
        send("#{key}=", val)
      end
    end
  end
end

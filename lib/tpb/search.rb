require "faraday"
require "nokogiri"

module TPB
  class Search
    def initialize(query)
      @query = query
      @proto = "https"
      @domain = "thepiratebay.se"
    end

    def results
      page = 0
      sort = sorts[:seeders].first
      category = categories[:video_hd_movies]

      res = Faraday.get(url("/search/#{@query}/#{page}/#{sort}/#{category}"))

      if res.status == 200
        doc = Nokogiri::HTML(res.body)
        results = doc.css("#searchResult tr:not(.header)").map do |row|
          cells = row.css("td")

          name = cells[1].css(".detLink").first

          Result.new(
            name:        name.text,
            url:         url(name["href"]),
            seeders:     cells[2].text.to_i,
            leechers:    cells[3].text.to_i,
            magnet_url:  (link = cells[1].css("a[title='Download this torrent using magnet']").first) && link["href"],
            torrent_url: (link = cells[1].css("a[title='Download this torrent']").first) && link["href"]
          )
        end
      else
        raise RuntimeError.new("Expected 200, got: #{res.status}")
      end
    end

    private

    def url(path)
      "#{@proto}://#{@domain}#{path}"
    end

    def sorts
      {
        name:        [1, 2],
        uploaded_at: [3, 4],
        size:        [5, 6],
        seeders:     [7, 8],
        leechers:    [9, 10],
        uploaded_by: [11, 12],
        type:        [13, 14]
      }
    end

    def categories
      {
        video_hd_movies: 207
      }
    end
  end
end

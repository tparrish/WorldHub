class BitlyAPI
    def self.shorten(url)
      client.shorten(url).short_url
    end
  
    def self.stats(url)
      client.stats(shorten(url)).stats.symbolize_keys
    end
  
    private
    def self.client
      Bitly.new(Configuration.bitly.username, Configuration.bitly.api_key)
    end
end
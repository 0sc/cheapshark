CHEAPSHARKURL = "http://www.cheapshark.com/api/1.0/"

class Cheapshark
  class << self
    def get_deals(options)
      response = make_request(options.to_param + "&pageSize=5")
      return [] if response.empty?
      prepare_response_list(response)
    end

    def get_deal_info(deal_id)
      response = make_request("id=#{deal_id}")
      return [] if response.empty?
      prepare_response_single(response, deal_id)
    end

    def make_request(params)
      url = CHEAPSHARKURL + "deals?" + params
      JSON.parse(Faraday.get(url).body)
    end

    def prepare_response_list(package)
      elements = []
      package.each do |pkg|
        elements << {
          title: pkg["title"] || pkg["gameInfo"]["name"],
          image_url: pkg["thumb"] || pkg["gameInfo"]["thumb"],
          subtitle: "Sale Price: #{pkg["salePrice"]}; Normal Price: #{pkg["normalPrice"] || pkg["gameInfo"]["retailPrice"]}; ",
          buttons: [
            {
              type: "web_url",
              url: "http://www.cheapshark.com/redirect?dealID=" + pkg["dealID"],
              title: "View Item"
            }
          ]
        }
      end
      elements
    end

    def prepare_response_single(package, id)
      package["dealID"] = id
      prepare_response_list([package])
    end
  end
end

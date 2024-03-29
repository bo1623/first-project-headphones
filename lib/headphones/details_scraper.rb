
class DetailsScraper #creating this class to accommodate the #more_details method in our controller

  attr_accessor :url,:details

  def initialize(url)
    @details=Nokogiri::HTML(open(url))
  end

  def scrape_prices
    sellers=[]
    @details.css("div[section='wtbSmall'] div.col-3").each do |i|
      hash={
        price: i.css("span[section*='price']").text.strip,
        #[attribute*=value] enables us to select elements whose attribute value contains a specified value
        #the value does not have to be a whole word
        seller: i.css("span[section*='seller']").text.strip
      }
      sellers << hash
    end
    sellers
  end

  def scrape_review
    hash={
      good: @details.css("p.theGood span.content").text.strip,
      bad: @details.css("p.theBad span.content").text.strip,
      bottom_line: @details.css("p.theBottomLine span.content").text.strip,
    }
    hash
  end


end

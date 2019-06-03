
class DetailsScraper

  attr_accessor :url,:details

  @@details=nil

  def self.scrape_details(url)
    @@details=Nokogiri::HTML(open(url))
  end

  def self.scrape_prices #may wanna refactor so that we only scrape the details page once
    # details=Nokogiri::HTML(open(url))
    sellers=[]
    @@details.css("div[section='wtbSmall'] div.col-3").each do |i|
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

  def self.scrape_review
    hash={
      good: @@details.css("p.theGood span.content").text.strip,
      bad: @@details.css("p.theBad span.content").text.strip,
      bottom_line: @@details.css("p.theBottomLine span.content").text.strip,
    }
    hash
  end


  def self.details
    @@details
  end

end

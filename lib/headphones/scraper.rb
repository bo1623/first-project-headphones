require 'open-uri'
require 'nokogiri'
require 'pry'

class Headphones::Scraper
  def get_page
    Nokogiri::HTML(open("https://www.cnet.com/topics/headphones/best-headphones/stereo-bluetooth/"))
  end

  def stats
    headphones={}
    get_page.css("div.bestMeta a h5").each{|i| headphones[i.text.to_sym]={}} #creating a hash where keys are the name of the headphones
    price_array=[]
    get_page.css("div.pricing span.price").each do |i|
      price_array << i.text.gsub("$","").to_i
    end
    stats=[]
    get_page.css("div.subRatings ul").each do |stat| #creating an array of stats (ex-price) for each headphone
      stats_hash={
        design: stat.css(":nth-child(1n) span.rating").first.text.to_i,
        features: stat.css(":nth-child(2n) span.rating").first.text.to_i,
        sound: stat.css(":nth-child(3n) span.rating").text.to_i,
        value:stat.css(":nth-child(4n) span.rating").text.to_i
      }
      stats << stats_hash
    end
    index=0
    headphones.each do |headphone,stat| #iterating over the array of stats to add the stats into the "headphones" hash
      headphones[headphone]=stats[index]
      headphones[headphone][:price]=price_array[index]
      index+=1
    end
    headphones
  end

end

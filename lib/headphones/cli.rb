#this is our CLI controller class
require "pry"

class Headphones::CLI

  attr_accessor :list, :review

  def call
    puts "Top 15 Headphones to Own for 2019"
    make_headphones
    list_headphones
    menu
    more_details
    last_request
    goodbye
  end

  def make_headphones
    collection_hash=Headphones::Scraper.new.stats
    Headphone.create_from_collection(collection_hash)
    @list=Headphone.all
  end


  def list_headphones
    Headphone.all.each.with_index(1) do |headphone,index|
      puts "#{index}. #{headphone.name} - $#{headphone.price} || Design: #{headphone.design} - Features: #{headphone.features} - Sound: #{headphone.sound} - Value: #{headphone.value}"
    end
    puts ""
  end


  def list_sorted_headphones(list)
    list.each.with_index(1) do |headphone,index|
      puts "#{index}. #{headphone.name} - $#{headphone.price} || Design: #{headphone.design} - Features: #{headphone.features} - Sound: #{headphone.sound} - Value: #{headphone.value}"
    end
  end

  def menu
    puts <<-DOC.gsub /^\s*/, ""
      Please select category to sort by:
      1. Price
      2. Design
      3. Features
      4. Sound
      5. Value
      Enter "exit" to proceed
    DOC
    puts ""

    input=gets.chomp.downcase
    case input
    when "1"
      puts "Sort by price (cheapest to most expensive)"
      @list= Headphone.all.sort_by{|i| i.price}
      list_sorted_headphones(@list)
    when "2"
      puts "Sort by design"
      @list= Headphone.all.sort_by{|i| i.design}.reverse! #included reverse for all cases below so that the ones with higher points appear on top
      list_sorted_headphones(@list)
    when "3"
      puts "Sort by features"
      @list= Headphone.all.sort_by{|i| i.features}.reverse!
      list_sorted_headphones(@list)
    when "4"
      puts "Sort by sound"
      @list= Headphone.all.sort_by{|i| i.sound}.reverse!
      list_sorted_headphones(@list)
    when "5"
      puts "Sort by value"
      @list= Headphone.all.sort_by{|i| i.value}.reverse!
      list_sorted_headphones(@list)
    when "exit"
      return
    else
      puts "Please enter valid option"
      menu #restarts the menu process and repeats options available
    end
    puts ""
    menu #allows user to keep sorting according to different attributes until he/she decides to exit
  end

  def more_details
    puts ""
    puts "If you would like to compare prices or read a summarized review, please enter the headphone number from the list above:"
    input=gets.chomp.to_i
    if (1..15).to_a.include?(input)
      index=input-1
      url=@list[index].review_url
    else
      puts "Please enter a valid number between 1 to 15"
      more_details
    end
    #assign the input to a new variable over here so we can call the right price comparison or review
    puts <<-DOC.gsub /^\s*/, ""
    What would you like to know more about the #{@list[index].name}?
    1. Price Comparison
    2. Summarized Review
    DOC
    puts ""

    input = gets.chomp
    case input
    when "1"
      additional_scrape(url) #needs to be called so that @@details within the DetailsScraper
      #class contains the html data so that price_comparison can work
      price_comparison
    when "2"
      additional_scrape(url) #needs to be called so that @@details within the DetailsScraper
      #class contains the html data so that summary_review can work
      summary_review
    when "exit"
      return
    else
      puts "Please enter a valid option or 'exit'"
      more_details
    end
  end

  def additional_scrape(url) #to run the scrape_details method within the DetailsScraper
    #class. So that @@details contains the scraped html data
    @review=url
    DetailsScraper.scrape_details(@review)
  end

  def price_comparison
    puts ""
    prices_array=DetailsScraper.scrape_prices
    prices_array.each do |i|
      puts "#{i[:seller]} - #{i[:price]}"
    end
    puts "Please visit #{self.review} for more details."
    puts ""
  end

  def summary_review
    reviews=DetailsScraper.scrape_review
    puts <<-DOC.gsub /^\s*/, ""
    .....
    The Good - #{reviews[:good]}
    .....
    The Bad - #{reviews[:bad]}
    .....
    Bottom Line - #{reviews[:bottom_line]}
    .....
    Please visit #{self.review} for more details.
    .....
    DOC
    puts ""
  end

  def last_request
    puts "Would you like to continue browsing (y/n)?"
    input=gets.chomp.downcase
    if input!="y"
      return
    else
      puts ""
      puts <<-DOC.gsub /^\s*/, ""
      Please choose one of the following options:
      1. Return to view full list of headphones
      2. Return to compare prices or read summary review
      DOC
      input=gets.chomp
      case input
      when "1"
        menu
        more_details
      when "2"
        list_sorted_headphones(@list)
        puts ""
        more_details
      else
        puts "Please enter valid option"
        last_request
      end
    end
  end


  def goodbye
    puts "Thank you and have a nice day!"
  end

end

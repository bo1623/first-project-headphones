#this is our CLI controller class
require "pry"
require "colorize"

class Headphones::CLI

  attr_accessor :list, :review, :details, :index

  def call
    puts ""
    puts "Top 15 Headphones to Own for 2019".colorize(:cyan).underline
    make_headphones
    make_brand
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

  def make_brand
    brand_array=@list.map{|i| i.name.to_s.split().first}.uniq #to_s is to convert name of headphone from symbol to string
    brand_array.each{|brand| Brand.new(brand)} #creating new instance of each brand
    @list.each do |headphone|
      Brand.all.each do |brand|
        headphone.brand=brand if headphone.name.to_s.split().first == brand.name #each headphone belongs to a brand. each brand has many headphones
      end
    end
  end

  def list_headphones
    Headphone.all.each.with_index(1) do |headphone,index|
      puts '%-40.40s'%"#{index}. #{headphone.name}"+" $#{headphone.price} || Design: "+"%2.2s"%"#{headphone.design}"+" - Features: #{headphone.features} - Sound: "+"%2.2s"%"#{headphone.sound}"+" - Value: #{headphone.value} | Total: #{headphone.total}"
      #added format string e.g. '%-40.40s' so that the lists seem neater. the negative sign ensures the string is aligned to the left, otherwise it'll align to the right
    end
    puts ""
  end


  def list_sorted_headphones(list)
    list.each.with_index(1) do |headphone,index|
      puts '%-40.40s'%"#{index}. #{headphone.name}"+" $#{headphone.price} || Design: "+"%2.2s"%"#{headphone.design}"+" - Features: #{headphone.features} - Sound: "+"%2.2s"%"#{headphone.sound}"+" - Value: #{headphone.value} | Total: #{headphone.total}"
    end
  end

  def menu
    puts "Please select category to sort by:".colorize(:cyan)
    puts <<-DOC.gsub /^\s*/, ""
      1. Price
      2. Design
      3. Features
      4. Sound
      5. Value
      6. Brand
      7. Total
    DOC
    puts ""
    puts "Alternatively, please enter '8' if you would like to filter by brand".colorize(:cyan)
    puts ""
    puts "8. Filter by brand"
    puts ""
    puts "Enter 'exit' to proceed"

    input=gets.chomp.downcase
    case input
    when "1"
      puts ""
      puts "Sort by price (cheapest to most expensive)".colorize(:cyan)
      @list= Headphone.all.sort_by{|i| i.price}
      list_sorted_headphones(@list)
    when "2"
      puts ""
      puts "Sort by design".colorize(:cyan)
      @list= Headphone.all.sort_by{|i| i.design}.reverse! #included reverse for all cases below so that the ones with higher points appear on top
      list_sorted_headphones(@list)
    when "3"
      puts ""
      puts "Sort by features".colorize(:cyan)
      @list= Headphone.all.sort_by{|i| i.features}.reverse!
      list_sorted_headphones(@list)
    when "4"
      puts ""
      puts "Sort by sound".colorize(:cyan)
      @list= Headphone.all.sort_by{|i| i.sound}.reverse!
      list_sorted_headphones(@list)
    when "5"
      puts ""
      puts "Sort by value".colorize(:cyan)
      @list= Headphone.all.sort_by{|i| i.value}.reverse!
      list_sorted_headphones(@list)
    when "6"
      puts ""
      puts "Sort by brand".colorize(:cyan)
      @list= Headphone.all.sort_by{|i| i.brand.name}
      list_sorted_headphones(@list)
    when "7"
      puts ""
      puts "Sort by total".colorize(:cyan)
      @list= Headphone.all.sort_by{|i| i.total}.reverse!
      list_sorted_headphones(@list)
    when "8"
      puts ""
      puts "Filter by brand".colorize(:cyan)
      find_by_brand
    when "exit"
      return
    else
      puts ""
      puts "Please enter valid option".colorize(:light_red)
    end
    puts ""
    menu #allows user to keep sorting according to different attributes until he/she decides to exit
  end

  def find_by_brand
    puts ""
    puts "Please select your desired brand:"
    brand_array = Brand.all.map{|brand| brand.name}
    Brand.all.each.with_index(1){|brand,index| puts "#{index}. #{brand.name}"}
    input=gets.chomp.to_i
    if (1..11).to_a.include?(input)
      puts ""
      puts "Showing #{Brand.all[input-1].name} headphones:".colorize(:cyan)
      @list = Headphone.all.select{|headphone| headphone.brand == Brand.all[input-1]}
      list_sorted_headphones(@list)
    else
      puts ""
      puts "Please enter a valid number".colorize(:light_red)
      find_by_brand
    end
  end

  def more_details
    puts ""
    puts "If you would like to compare prices or read a summarized review, please enter the headphone number from the list below:".colorize(:cyan)
    puts ""
    list_sorted_headphones(@list)
    input=gets.chomp
    if input=="exit"
      return
    elsif (1..@list.size).to_a.include?(input.to_i)
      @index=input.to_i-1
      run_details
    else
      puts ""
      puts "Please enter 'exit' or a valid number between 1 to #{@list.size}".colorize(:light_red)
      more_details
    end
    #assign the input to a new variable over here so we can call the right price comparison or review
  end

  def run_details
    puts ""
    puts "What would you like to know more about the #{@list[@index].name}?".colorize(:cyan)
    puts <<-DOC.gsub /^\s*/, ""
    1. Price Comparison
    2. Summarized Review
    DOC
    puts ""
    #since the user has chosen a number already, we can be certain that they would like to view more details now
    #so it makes sense to scrape the additional details here
    additional_scrape(@list[@index].review_url) #needs to be called so that the DetailsScraper object gets initialized
    #with @details containing the html we'll be scraping - important for price_comparison and summary_review to work
    details_choice
  end

  def details_choice
    input = gets.chomp
    case input
    when "1"
      price_comparison
    when "2"
      summary_review
    when "exit"
      return
    else
      puts "Please enter a valid option or 'exit'".colorize(:light_red)
      details_choice
    end
  end

  def additional_scrape(url) #to run the scrape_details method within the DetailsScraper
    #class. So that @details contains the scraped html data
    @review=url #need this local variable for the 'Please visit randomheadphone.com for more details in #summary_review'
    @details=DetailsScraper.new(@review)
  end

  def price_comparison
    puts ""
    prices_array=@details.scrape_prices
    prices_array.each do |i|
      puts "#{i[:seller]} - #{i[:price]}"
    end
    puts "Please visit #{self.review} for more details."
    puts ""
  end

  def summary_review
    reviews=@details.scrape_review
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
    puts ""
    puts "Would you like to continue browsing (y/n)?".colorize(:cyan)
    input=gets.chomp.downcase
    if input!="y"
      return
    else
      puts ""
      puts "Please choose one of the following options:".colorize(:cyan)
      puts <<-DOC.gsub /^\s*/, ""
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
        puts "Please enter valid option".colorize(:light_red)
        last_request
      end
      last_request
    end
  end


  def goodbye
    puts ""
    puts "Thank you and have a nice day!".colorize(:cyan)
  end

end

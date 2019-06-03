#this is our CLI controller class
require "pry"

class Headphones::CLI

  attr_accessor :list, :review #maybe create instance variable list so that after sorting, the user can just hit the index
  #of the sorted list to get more details on their most recently printed list

  def call
    puts "Top 10 Headphones"
    make_headphones
    list_headphones
    puts ""
    menu
    more_details
    #maybe insert another function to bring us back to any of the previous methods "review"
    goodbye
  end

  def make_headphones
    collection_hash=Headphones::Scraper.new.stats
    Headphone.create_from_collection(collection_hash)
    @list=Headphone.all
  end


  def list_headphones
    Headphone.all.each.with_index(1) do |headphone,index|
      puts "#{index}. #{headphone.name} - USD #{headphone.price} || Design: #{headphone.design} - Features: #{headphone.features} - Sound: #{headphone.sound} - Value: #{headphone.value}"
    end
  end


  def list_sorted_headphones(list)
    list.each.with_index(1) do |headphone,index|
      puts "#{index}. #{headphone.name} - USD #{headphone.price} || Design: #{headphone.design} - Features: #{headphone.features} - Sound: #{headphone.sound} - Value: #{headphone.value}"
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
      Enter "exit" to quit programme
    DOC

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
    puts "If you would like to compare prices or read a detailed review, please enter the headphone number from the list above:"
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
    2. Detailed Review
    DOC

    input = gets.chomp
    case input
    when "1"
      price_comparison(url)
    when "2"
      puts "review"
    when "exit"
      return
    else
      puts "Please enter a valid option or 'exit'"
      more_details
    end
  end

  def price_comparison(url)
    @review=url
    prices_hash=Headphones::Scraper.new.scrape_prices(@review)
    prices_hash.each do |i|
      puts "#{i[:seller]} - #{i[:price]}"
    end
  end

  def goodbye
    puts "Thank you and have a nice day!"
  end

end

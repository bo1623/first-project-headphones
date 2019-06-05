class Headphone

  attr_accessor :name, :price, :design, :features, :sound, :value, :total, :review_url, :comparison_url

  @@all=[]

  def initialize(name,stats)
    @name=name
    stats.each{|k,v| self.send("#{k}=",v)}
    @@all << self
  end

  def self.create_from_collection(collection_hash)
    collection_hash.each{|name,stats| self.new(name,stats)} #makes a new instance out of each headphone hash
  end

  def self.all
    @@all
  end

end

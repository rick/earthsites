class YahooXMLParser
  def initialize(options)
    @verbose = options[:verbose]
  end
  
  def verbose?
    !!@verbose
  end
  
  def process!
    fetch!
  end

  def fetch!
  end
end
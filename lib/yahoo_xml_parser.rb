class YahooXMLParser
  def initialize(options)
    @verbose = options[:verbose]
  end
  
  def verbose?
    !!@verbose
  end
end
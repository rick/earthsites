class YahooXMLParser
  def initialize(options)
    @verbose = options[:verbose]
  end
  
  def verbose?
    !!@verbose
  end
  
  def process!
    upload!(transform_xml)
  end
end
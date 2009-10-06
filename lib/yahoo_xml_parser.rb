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
  
  def transform_xml
    doc = xml
    raise "XML document is not valid.  [#{doc}]" unless valid_xml?(doc)
  end
end
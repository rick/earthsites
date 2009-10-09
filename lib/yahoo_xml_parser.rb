require 'nokogiri'

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
    doc = parsed_xml
    raise "XML document is not valid:\n  [#{doc}]" unless valid_xml?(doc)
  end
  
  def valid_xml?(parsed)
    return false if     parsed.xpath('/Catalog').empty?
    return false unless parsed.xpath('/Catalog').first['StoreID']
    return false unless parsed.xpath('/Catalog').first['StoreName']

    items = parsed.xpath('/Catalog/Item')
    item_ids = items.collect {|item| item['ID'] }

    return false if items.empty?
    return false if items.any? {|item| item['ID'].nil? }
    return false if item_ids.size != item_ids.uniq.size  # detect duplicate item id's

    # ensure that all items have item fields  
    return false if items.any? {|item| item.xpath('ItemField').empty? }

    # ensure that all item fields are valid
    return false if items.xpath('ItemField').any? {|itemfield| itemfield['TableFieldID'].nil? }
    return false if items.xpath('ItemField').any? {|itemfield| itemfield['Value'].nil? }

    # require values for specific fields
    ['name', 'taxable', 'code', 'need-ship', 'condition'].each do |field|
      return false if item_has_no_value_for?(items, field)
    end
    
    true
  end
  
  def item_has_no_value_for?(items, name)
    items.xpath("ItemField[@TableFieldID='#{name}']").first['Value'] == ''
  end
end
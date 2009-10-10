require 'parser'

class YahooXMLParser < Parser

  # per-class method - mapping: ordered list of pairs -- first is destination name, last is conversion on source record
  # a simple string denotes a source key, proc denotes a method on source record
  def conversion_map
    @conversion_map ||= 
      [
        [ 'Name', 'name' ],
        [ 'Discount', Proc.new {|source| "%0.2f" % (source['price'].to_f - source['sale-price'].to_f) } ]
      ]
  end
  
  # per-class method
  def deserialize(doc)
    parsed = from_xml(doc)
    STDERR.puts "Validating document..." if verbose?
    raise "document is not valid:\n  [#{document}]" unless valid?(parsed)
    STDERR.puts "Finished document validation." if verbose?
    result = parsed.xpath('/Catalog/Item').inject([]) {|a,i| h= {}; a << h;  i.xpath('ItemField').each{|f| h[f['TableFieldID']] = f['Value'] }; a }
    result
  end
  
  # per-class method
  # TODO:  lift up to #to_csv in base class
  def serialize(data)
    FasterCSV.generate(:write_headers => true, :headers => destinations) do |csv|
      data.each {|record| csv << record_to_array(record) }
    end
  end

  # per-class method
  def valid?(parsed)
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
      return false if items.xpath("ItemField[@TableFieldID='#{field}']").first['Value'] == ''
    end
    
    true
  end
end
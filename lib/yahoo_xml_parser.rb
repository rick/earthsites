require 'parser'

class Object
  def blank?
    !self || nil? || (respond_to?(:empty?) ? empty? : false)
  end
end

class Object  
  def unless_blank?
    blank? ? false : self
  end
end

class YahooXMLParser < Parser
  # per-class method - mapping: ordered list of pairs -- first is destination name, last is conversion on source record
  # a simple string denotes a source key, proc denotes a method on source record
  def conversion_map
    @conversion_map ||= 
      [
      # [ 'destination', 'source' ],
        [ 'seller',    
          Proc.new do |row| 
            'Friends of Tilonia' 
          end
        ],
        [ 'seller_code', 'id' ],
        [ 'name',      'name'],
        [ 'short', 
          Proc.new do |row| 
            row['abstract'].unless_blank? || row['product-ads-description'].unless_blank? || ''
          end
        ],
        [ 'description', 
          Proc.new do |row| 
            row['top-featured-text'].unless_blank? || row['caption'].unless_blank? || ''
          end
        ],
        [ 'maker',  
          Proc.new do |row|
            if row['code'] =~ /^AV-/ or row['name'] =~ /avani/i
              'Avani'
            else
              'Tilonia'
            end    
          end
        ],
        [ 'maker_code',  
          Proc.new do |row|
            if row['code'] =~ /^AV-/ or row['name'] =~ /avani/i
              row['code'].sub(/^(?:AV-)|(?:Avani)/, '').sub(/^([a-zA-Z]+)(\d+[aA]?)$/, '\1-\2') 
            else
              row['code']
            end    
          end
        ],
        [ 'images', 
          Proc.new do |row|
            images = ['image', 'image-top-left', 'inset', 'inset-1', 'inset-2' ].inject([]) do |list, img_field|
              if row[img_field] =~ /src/
                list << row[img_field].sub(/^.*src=(.*)[&>].*$/, '\1')
              end
              list
            end
            images.join('|')
          end
        ],
        [ 'image_sizes', 
          Proc.new do |row|
            images = ['image', 'image-top-left', 'inset', 'inset-1', 'inset-2'].inject([]) do |list, img_field|
              if row[img_field] =~ /src/
                width = row[img_field].sub(/^.*width=(\d+).*$/, '\1')
                height = row[img_field].sub(/^.*height=(\d+).*$/, '\1')
                list << "#{width}x#{height}"
              end
              list
            end
            images.join('|')
          end
        ],
        [ 'price', 'price'],
        [ 'taxable', 'taxable'],
        [ 'download',  'download'],
        [ 'tilonia_code', 'code'],
        [ 'related', 'cross-sell'],
        [ 'orderable', 'orderable'],
        [ 'size', 'size'],
        [ 'color', 'color'],
        [ 'fabric', 'fabric'],
        [ 'condition', 'condition'],
        [ 'keywords', 'keywords'],
        [ 'gift_certificate', 'gift-certificate'],
        [ 'need_shipping', 'need-ship'],
        [ 'wholesaleable', 
          Proc.new do |row|
            row['wholesale-text'].blank? ? 'f' : 't'
          end
        ],
        [ 'featured_header', 'top-featured-text-header'],
        [ 'yahoo_code', 'ID'],
        [ 'yahoo_category', 'yahoo-shopping-category'],
        [ 'yahoo_merchant_category', 'merchant-category'],
        [ 'yahoo_sale_price', 'sale-price'],
        [ 'yahoo_multi_add', 'multi-add'],
        [ 'yahoo_ypath', 'ypath'],
        [ 'yahoo_product_ads_category', 'product-ads-category'],
      ]
  end
  
  # per-class method
  def deserialize(doc)
    parsed = from_xml(doc)
    STDERR.puts "Validating document..." if verbose?
    raise "document is not valid:\n  [#{document}]" unless valid?(parsed)
    STDERR.puts "Finished document validation." if verbose?
    result = parsed.xpath('/Catalog/Item').inject([]) do |a,item| 
      h = { 'id' => item['ID']}
      item.xpath('ItemField').each { |f| h[f['TableFieldID']] = f['Value'] }
      a << h unless h['product-ads-exclude'] == 't'
      a
    end
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
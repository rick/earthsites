$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. lib])))
require 'yahoo_xml_parser'

DATA_PATH = File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. cache]))

# convert XML to a format that ActiveWarehouse can deal w/ (whytf did they write their own shitty XML parser?)
infile = File.join(DATA_PATH, 'catalog.xml')
outfile = File.join(DATA_PATH, 'yahoo-catalog.csv')

puts "converting XML data from [#{infile}]..."
parser = YahooXMLParser.new(:url => infile)
csv    = parser.process!
puts "writing CSV data to [#{outfile}]"
File.open(outfile, 'w') {|f| f.puts csv }


source :in, {
  :file   => outfile,
  :parser => :delimited,
  :skip_lines => 1,
},
[    
  :seller, :seller_code, :name, :short, :description, :maker, :maker_code, :images, :image_sizes, 
  :price, :taxable, :download, :tilonia_code, :related, :orderable, :size, :color, 
  :fabric, :condition, :keywords, :gift_certificate, :need_shipping, :wholesaleable, 
  :featured_header, :yahoo_code, :yahoo_category, :yahoo_merchant_category, :yahoo_sale_price, 
  :yahoo_multi_add, :yahoo_ypath, :yahoo_product_ads_category
]

rename :maker_code, :product_id
rename :seller_code, :product_code
rename :price, :unit_price
rename :maker, :vendor

destination :out, {
  :file => '../output/catalog.txt',
  :type => 'csv'
},
{
  :order => [ :product_id, :product_code, :description, :unit_price, :vendor ]
}

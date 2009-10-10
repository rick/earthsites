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
  :name, 
  :discount
]

destination :out, {
  :file => '../output/catalog.txt'
},
{
  :order => [ :discount, :name ]
}

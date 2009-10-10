require File.expand_path(File.join(File.dirname(__FILE__), *%w[spec_helper]))
require 'yahoo_xml_parser'
require 'parser_behavior'

def parse(xml)
  Nokogiri::XML.parse(xml)
end

def read_xml_fixture
  File.read(File.join(File.dirname(__FILE__), *%w[.. fixtures catalog.xml]))
end

describe 'Yahoo XML Parser' do
  before do
    @class = YahooXMLParser
    @parser = @class.new({})
  end
  
  behaves_like 'a parser'  

  describe 'when validating an XML document' do
    before do
      @xml = read_xml_fixture
      @parsed = parse(@xml)
    end
    
    it 'should accept a parsed XML document' do
      lambda { @parser.valid?(@parsed) }.should.not.raise(ArgumentError)
    end
    
    it 'should require a parsed XML document' do
      lambda { @parser.valid? }.should.raise(ArgumentError)
    end
    
    it 'should consider a valid parsed Yahoo Store XML dump to be valid' do
      @parser.valid?(@parsed).should.be.true
    end

    it 'should require the XML root element to be a catalog element' do
      @parsed.xpath('/Catalog').first.name = 'foo'
      @parser.valid?(@parsed).should.be.false
    end
    
    it 'should require the XML root element to specify a store id' do
      @parsed.xpath('/Catalog').first.delete('StoreID')
      @parser.valid?(@parsed).should.be.false      
    end
    
    it 'should require the XML root element to specify a store name' do
      @parsed.xpath('/Catalog').first.delete('StoreName')
      @parser.valid?(@parsed).should.be.false
    end
    
    it 'should require the XML document to describe some set of items' do
      @parsed.xpath('/Catalog/Item').each {|item| item.name = 'NonItem' }
      @parser.valid?(@parsed).should.be.false      
    end
    
    it 'should require all items to have an item ID' do
      @parsed.xpath('/Catalog/Item').last.delete('ID')
      @parser.valid?(@parsed).should.be.false      
    end

    it 'should require all items to have unique item IDs' do
      items = @parsed.xpath('/Catalog/Item')
      items.last['ID'] = items.first['ID']
      @parser.valid?(@parsed).should.be.false      
    end
    
    it 'should require all items to have item fields' do
      item = @parsed.xpath('/Catalog/Item').last
      item.xpath('ItemField').each {|item_field| item_field.name = 'Foo' }
      @parser.valid?(@parsed).should.be.false      
    end
    
    it 'should require all item fields to have table field ids ' do
      item = @parsed.xpath('/Catalog/Item').last
      item.xpath('ItemField').last.delete('TableFieldID')
      @parser.valid?(@parsed).should.be.false    
    end

    it 'should require all item fields to have values' do
      item = @parsed.xpath('/Catalog/Item').last
      item.xpath('ItemField').last.delete('Value')
      @parser.valid?(@parsed).should.be.false    
    end

    [ 'name', 'taxable', 'code', 'need-ship', 'condition' ].each do |field|
      it "should require all items to have non-empty #{field} values" do
        parsed = parse(@xml)
        parsed.xpath("/Catalog/Item/ItemField[@TableFieldID='#{field}']").first['Value'] = ''
        @parser.valid?(parsed).should.be.false      
      end
    end    
  end
end

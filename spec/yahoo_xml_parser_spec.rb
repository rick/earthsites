require File.expand_path(File.join(File.dirname(__FILE__), *%w[spec_helper]))
require 'yahoo_xml_parser'
require 'nokogiri'

describe 'Yahoo XML Parser' do
  describe 'when initializing' do
    it 'should accept an options hash' do
      lambda { YahooXMLParser.new({}) }.should.not.raise(ArgumentError)
    end
    
    it 'should require an options hash' do
      lambda { YahooXMLParser.new }.should.raise(ArgumentError)      
    end
    
    it 'should return a verbose parser if the verbose option is set' do
      YahooXMLParser.new(:verbose => true).verbose?.should.be.true
    end
    
    it 'should return a non-verbose parser if the verbose option is false' do
      YahooXMLParser.new(:verbose => false).verbose?.should.be.false
    end
    
    it 'should return a non-verbose parser if the verbose option is missing' do
      YahooXMLParser.new({}).verbose?.should.be.false
    end
  end
  
  describe 'when processing Yahoo XML' do
    before do
      @parser = YahooXMLParser.new({})
      @transformed = { :transformed => :xml }
      @parser.stub!(:transform_xml).and_return(@transformed)
      @parser.stub!(:upload!).and_return(true)
    end
    
    it 'should work without arguments' do
      lambda { @parser.process! }.should.not.raise(ArgumentError)
    end
    
    it 'should not allow arguments' do
      lambda { @parser.process!(:foo) }.should.raise(ArgumentError)      
    end
    
    it 'should transform the XML document' do
      @parser.should.receive(:transform_xml).and_return(@transformed)
      @parser.process!
    end
        
    it 'should fail if transforming the XML document fails' do
      @parser.stub!(:transform_xml).and_raise(RuntimeError)
      lambda { @parser.process! }.should.raise(RuntimeError)
    end

    it 'should upload the transformed XML document' do
      @parser.should.receive(:upload!).with(@transformed)
      @parser.process!
    end
    
    it 'should fail if uploading the transformed XML document fails' do
      @parser.stub!(:upload!).and_raise(RuntimeError)
      lambda { @parser.process! }.should.raise(RuntimeError)
    end
    
    it 'should return the result of uploading the transformed XML document' do
      @parser.process!.should.be.true
    end
  end
  
  describe 'when transforming an XML document' do
    before do
      @parser = YahooXMLParser.new({})
      @xml = 'sample XML document'
      @parser.stub!(:parsed_xml).and_return(@xml)
      @parser.stub!(:valid_xml?).with(@xml).and_return(true)
    end
    
    it 'should work without arguments' do
      lambda { @parser.transform_xml }.should.not.raise(ArgumentError)
    end
    
    it 'should not allow arguments' do
      lambda { @parser.transform_xml(:foo) }.should.raise(ArgumentError)
    end
    
    it 'should fail if the parsed XML document cannot be retrieved' do
      @parser.stub!(:parsed_xml).and_raise(RuntimeError)
      lambda { @parser.transform_xml }.should.raise(RuntimeError)
    end
    
    it 'should fail if the XML document is not a valid Yahoo Store XML dump' do
      @parser.stub!(:valid_xml?).and_return(false)
      lambda { @parser.transform_xml }.should.raise(RuntimeError)
    end
    
    # TODO: produce a CSV export
  end
  
  describe 'when uploading transformed XML' do
    
  end
  
  describe 'parsed XML document' do
    
  end
  
  describe 'when validating an XML document' do
    def parse(xml)
      Nokogiri::XML.parse(xml)
    end
    
    before do
      @parser = YahooXMLParser.new({})
      @xml = File.read(File.join(File.dirname(__FILE__), *%w[.. fixtures catalog.xml]))
      @parsed = parse(@xml)
    end
    
    it 'should accept a parsed XML document' do
      lambda { @parser.valid_xml?(@parsed) }.should.not.raise(ArgumentError)
    end
    
    it 'should require a parsed XML document' do
      lambda { @parser.valid_xml? }.should.raise(ArgumentError)
    end
    
    it 'should consider a valid parsed Yahoo Store XML dump to be valid' do
      @parser.valid_xml?(@parsed).should.be.true
    end

    it 'should require the XML root element to be a catalog element' do
      @parsed.xpath('/Catalog').first.name = 'foo'
      @parser.valid_xml?(@parsed).should.be.false
    end
    
    it 'should require the XML root element to specify a store id' do
      @parsed.xpath('/Catalog').first.delete('StoreID')
      @parser.valid_xml?(@parsed).should.be.false      
    end
    
    it 'should require the XML root element to specify a store name' do
      @parsed.xpath('/Catalog').first.delete('StoreName')
      @parser.valid_xml?(@parsed).should.be.false
    end
    
    it 'should require the XML document to describe some set of items' do
      @parsed.xpath('/Catalog/Item').each {|item| item.name = 'NonItem' }
      @parser.valid_xml?(@parsed).should.be.false      
    end
    
    it 'should require all items to have an item ID' do
      @parsed.xpath('/Catalog/Item').last.delete('ID')
      @parser.valid_xml?(@parsed).should.be.false      
    end

    it 'should require all items to have unique item IDs' do
      items = @parsed.xpath('/Catalog/Item')
      items.last['ID'] = items.first['ID']
      @parser.valid_xml?(@parsed).should.be.false      
    end
    
    it 'should require all items to have item fields' do
      item = @parsed.xpath('/Catalog/Item').last
      item.xpath('ItemField').each {|item_field| item_field.name = 'Foo' }
      @parser.valid_xml?(@parsed).should.be.false      
    end
    
    it 'should require all item fields to have table field ids ' do
      item = @parsed.xpath('/Catalog/Item').last
      item.xpath('ItemField').last.delete('TableFieldID')
      @parser.valid_xml?(@parsed).should.be.false    
    end

    it 'should require all item fields to have values' do
      item = @parsed.xpath('/Catalog/Item').last
      item.xpath('ItemField').last.delete('Value')
      @parser.valid_xml?(@parsed).should.be.false    
    end

    [ 'name', 'taxable', 'code', 'need-ship', 'condition' ].each do |field|
      it "should require all items to have non-empty #{field} values" do
        parsed = parse(@xml)
        parsed.xpath("/Catalog/Item/ItemField[@TableFieldID='#{field}']").first['Value'] = ''
        @parser.valid_xml?(parsed).should.be.false      
      end
    end    
  end
end
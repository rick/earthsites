require File.expand_path(File.join(File.dirname(__FILE__), *%w[spec_helper]))
require 'yahoo_xml_parser'

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
end
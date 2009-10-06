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
    end
    
    it 'should work without arguments' do
      lambda { @parser.process! }.should.not.raise(ArgumentError)
    end
    
    it 'should not allow arguments' do
      lambda { @parser.process!(:foo) }.should.raise(ArgumentError)      
    end
    
    it 'should fetch a copy of the most recent Yahoo XML dump' do
      @parser.should.receive(:fetch!)
      @parser.process!
    end
    
    it 'should fail if fetching the most recent Yahoo XML dump fails' do
      @parser.should.receive(:fetch!).and_raise(RuntimeError)
      lambda { @parser.process! }.should.raise(RuntimeError)
    end
  end
end
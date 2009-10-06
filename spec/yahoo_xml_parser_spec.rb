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
end
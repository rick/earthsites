require 'rubygems'
require 'nokogiri'

require File.expand_path(File.join(File.dirname(__FILE__), *%w[spec_helper]))
require 'parser_behavior'
require 'parser'

describe 'Parser' do
  before do
    @class = Parser
    @parser = Parser.new({})
  end
  
  behaves_like 'a parser'
  
  describe 'when looking up a conversion map from input fields to output fields' do
    # Note:  NotImplementedError doesn't seem to be caught by the normal lambda {} construct.
    
    it 'should not allow arguments' do
      lambda { @parser.conversion_map(:foo) }.should.raise(ArgumentError)      
    end
    
    it 'should require subclasses to implement this functionality' do
      lambda { @parser.conversion_map }.should.raise(NotImplementedError)
    end
  end
  
  describe 'when deserializing input data' do
    before do
      @document = 'Test Document'
    end
  
    # Note:  NotImplementedError doesn't seem to be caught by the normal lambda {} construct.
    
    it 'should require a document' do
      lambda { @parser.deserialize }.should.raise(ArgumentError)      
    end
    
    it 'should require subclasses to implement this functionality' do
      lambda { @parser.deserialize(@document) }.should.raise(NotImplementedError)
    end
  end
  
  describe 'when serializing output data' do
    before do
      @data = 'Test Data'
    end

    # Note:  NotImplementedError doesn't seem to be caught by the normal lambda {} construct.
  
    it 'should require a data set' do
      lambda { @parser.serialize }.should.raise(ArgumentError)      
    end
  
    it 'should require subclasses to implement this functionality' do
      lambda { @parser.serialize(@data) }.should.raise(NotImplementedError)
    end
  end
  
  describe 'when checking the validity of an input document' do
    before do
      @document = 'Test Document'
    end
  
    # Note:  NotImplementedError doesn't seem to be caught by the normal lambda {} construct.
    
    it 'should require a document' do
      lambda { @parser.valid? }.should.raise(ArgumentError)      
    end
    
    it 'should require subclasses to implement this functionality' do
      lambda { @parser.valid?(@document) }.should.raise(NotImplementedError)
    end
  end
end

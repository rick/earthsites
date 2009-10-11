require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))
require 'yahoo_xml_parser'

def run_command
  eval File.read(File.join(File.dirname(__FILE__), *%w[.. .. bin process_yahoo_xml.rb]))
end

describe 'process_yahoo_xml command' do
  before do
    @parser = 'fake yahoo xml parser'
    @parser.stub!(:process!)
    YahooXMLParser.stub!(:new).and_return(@parser)
    self.stub!(:puts)
  end

  describe 'when no command-line arguments are specified' do
    it 'should run successfully' do
      Object.send(:remove_const, :ARGV)
      ARGV = []
      lambda { run_command }.should.not.raise(Errno::ENOENT)
    end
    
    it 'should create a yahoo xml parser' do
      YahooXMLParser.should.receive(:new).and_return(@parser)
      run_command
    end
    
    it "should pass an empty set of options" do
      YahooXMLParser.should.receive(:new).with({}).and_return(@parser)      
      run_command
    end
  end

  describe "when -v is specified on the command-line" do
    before do
      Object.send(:remove_const, :ARGV)
      ARGV = ['-v']
    end
    
    it 'should create a yahoo xml parser' do
      YahooXMLParser.should.receive(:new).and_return(@parser)
      run_command
    end
    
    it "should set the option to be verbose" do
      YahooXMLParser.should.receive(:new).with(:verbose => true).and_return(@parser)      
      run_command
    end
  end

  describe "when --verbose is specified on the command-line" do
    before do
      Object.send(:remove_const, :ARGV)
      ARGV = ['--verbose']
    end
    
    it 'should create a yahoo xml parser' do
      YahooXMLParser.should.receive(:new).and_return(@parser)
      run_command
    end
    
    it "should set the option to be verbose" do
      YahooXMLParser.should.receive(:new).with(:verbose => true).and_return(@parser)      
      run_command
    end
  end

  describe "when -u URL is specified on the command-line" do
    before do
      Object.send(:remove_const, :ARGV)
      ARGV = ['-u', 'http://www.domain.com/']
    end
    
    it 'should create a yahoo xml parser' do
      YahooXMLParser.should.receive(:new).and_return(@parser)
      run_command
    end
    
    it "should set the url option to the value provided" do
      YahooXMLParser.should.receive(:new).with(:url => 'http://www.domain.com/').and_return(@parser)      
      run_command
    end
  end

  describe "when --url URL is specified on the command-line" do
    before do
      Object.send(:remove_const, :ARGV)
      ARGV = ['--url', 'http://www.domain.com/']
    end
    
    it 'should create a yahoo xml parser' do
      YahooXMLParser.should.receive(:new).and_return(@parser)
      run_command
    end
    
    it "should set the option to be verbose" do
      YahooXMLParser.should.receive(:new).with(:url => 'http://www.domain.com/').and_return(@parser)      
      run_command
    end
  end

  describe "when -h is specified on the command-line" do
    before do
      Object.send(:remove_const, :ARGV)
      ARGV = ['-h']
    end
    
    it 'should display usage information' do
      self.should.receive(:puts)
      run_command
    end
    
    it 'should not create a yahoo xml parser' do
      YahooXMLParser.should.not.receive(:new)
      run_command
    end
    
    it 'should not attempt to process Yahoo Stores XML' do
      @parser.should.not.receive(:process!)
      run_command
    end
  end

  describe "when --help is specified on the command-line" do
    before do
      Object.send(:remove_const, :ARGV)
      ARGV = ['--help']
    end
    
    it 'should display usage information' do
      self.should.receive(:puts)
      run_command
    end
    
    it 'should not create a yahoo xml parser' do
      YahooXMLParser.should.not.receive(:new)
      run_command
    end
    
    it 'should not attempt to process Yahoo Stores XML' do
      @parser.should.not.receive(:process!)
      run_command
    end
  end

  it 'should use the created xml parser to process the Yahoo Stores XML dump' do
    @parser.should.receive(:process!)
    run_command
  end
end
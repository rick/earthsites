require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))
require 'yahoo_xml_parser'

def run_command
  eval File.read(File.join(File.dirname(__FILE__), *%w[.. .. bin process_yahoo_xml.rb]))
end

describe 'process_yahoo_xml command' do
  before do
    @parser = 'fake yahoo xml parser'
    self.stub!(:exit)
    self.stub!(:puts)
  end

  it 'should run when no command-line arguments are specified' do
    Object.send(:remove_const, :ARGV)
    ARGV = []
    lambda { run_command }.should.not.raise(Errno::ENOENT)
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
    
    it 'should exit with status 0' do
      self.should.receive(:exit).with(0)
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
    
    it 'should exit with status 0' do
      self.should.receive(:exit).with(0)
      run_command
    end
  end
end
require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe 'process_yahoo_xml command' do
  before do
    self.stub!(:exit)
    self.stub!(:puts)
  end

  def run_command
    eval File.read(File.join(File.dirname(__FILE__), *%w[.. .. bin process_yahoo_xml.rb]))
  end

  it 'should run when no command-line arguments are specified' do
    Object.send(:remove_const, :ARGV)
    ARGV = []
    lambda { run_command }.should.not.raise(Errno::ENOENT)
  end
end
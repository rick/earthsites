require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.on('-v', '--verbose', 'verbosely display progress and errors')
  opts.on_tail('-h', '--help', 'show this message') do
    puts opts
    options[:help] = true
  end
end.parse!

YahooXMLParser.new(:verbose => true) unless options[:help]
exit(0)
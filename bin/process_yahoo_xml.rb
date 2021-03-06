#!/usr/bin/env ruby

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'optparse'
require 'yahoo_xml_parser'

options = {}
OptionParser.new do |opts|
  opts.on('-u', '--url URL', 'specify URL from which to fetch data') do |url|
    options[:url] = url
  end
  
  opts.on('-v', '--verbose', 'verbosely display progress and errors') do
    options[:verbose] = true
  end
  
  opts.on_tail('-h', '--help', 'show this message') do
    puts opts
    options[:help] = true
  end
end.parse!

YahooXMLParser.new(options).process! unless options[:help]
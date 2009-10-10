require 'rubygems'
require 'nokogiri'
require 'fastercsv'
require 'open-uri'

class Parser
  attr_reader :url
  
  def initialize(options)
    @verbose = options[:verbose]
    @url = options[:url]
    @cache = options[:cache]
  end
  
  def verbose?
    !!@verbose
  end
  
  def document
    @document ||= fetch
  end
  
  def process!
    write!(to_output)
  end
  
  def write!(data)
    data
  end
  
  def to_output
    serialize(convert(from_input))
  end
  
  def from_input
    deserialize(document)
  end
  
  # fetch document from url, falling back to cache in case of failure to read, updating cache if successful
  def fetch
    save(read(url))
  rescue Exception => e
    STDERR.puts "WARNING: using cached file due to error fetching [#{url}]: #{e.to_s}" rescue nil
    cached
  end

  def read(url)
    STDERR.puts "Reading data from [#{url}]" if verbose?
    result = open(url) {|f| return f.read }
    STDERR.puts "Finished reading [#{url}]" if verbose?
    result
  end
  
  # update cache of remote file contents; return contents when finished
  def save(contents)
    STDERR.puts "Caching data in [#{cache_file}]" if verbose?
    File.open(cache_file, 'w') {|f| f.puts contents }
    STDERR.puts "Finished updating cache." if verbose?
  rescue Exception => e
    STDERR.puts "WARNING:  Unable to update cache file [#{cache_file}] for contents of [#{url}]: #{e.to_s}"
  ensure
    return contents
  end
  
  def cached
    STDERR.puts "Reading data from cache file [#{cache_file}]" if verbose?
    result = File.read(cache_file)
    STDERR.puts "Finished reading cache." if verbose?
    result
  end
  
  def cache
    @cache ||= File.expand_path(File.join(File.dirname(__FILE__), *%w[.. cache]))
  end
  
  def filename
    File.basename(URI.parse(url).path)
  end
  
  def cache_file
    File.join(cache, filename)
  end
  
  def from_xml(doc)
    STDERR.puts "Parsing XML..." if verbose?
    result = Nokogiri::XML::parse(doc)
    STDERR.puts "Finished parsing." if verbose?
    result
  end
  
  def mapping
    @mapping ||= conversion_map.inject({}) {|h, pair| h[pair.first] = pair.last; h }
  end
  
  def destinations
    @destinations ||= conversion_map.collect {|rule| rule.first }.flatten
  end
  
  def convert(list)
    STDERR.puts "Converting data..." if verbose?
    result = list.inject([]) {|records, row| records << convert_row(row) }
    STDERR.puts "Finished conversion." if verbose?
    result
  end
  
  def convert_row(row)
    destinations.inject({}) do |result, dest|
      mapping.each_pair {|name, converter| result[name] = change(converter, row) }
      result
    end    
  end

  def change(rule, row)
    return rule.call(row) if rule.respond_to?(:call)
    row[rule]
  end

  def record_to_array(record)
    destinations.inject([]) {|l, name| l << record[name] }
  end  
  
  # per-class method - mapping: ordered list of pairs -- first is destination name, last is conversion on source record
  # a simple string denotes a source key, proc denotes a method on source record
  def conversion_map
    raise NotImplementedError
  end
  
  # per-class method
  def deserialize(doc)
    raise NotImplementedError
  end
  
  # per-class method
  def serialize(data)
    raise NotImplementedError
  end

  # per-class method
  def valid?(parsed)
    raise NotImplementedError
  end
end

shared "a parser" do
  describe 'when initializing' do
    it 'should accept an options hash' do
      lambda { @class.new({}) }.should.not.raise(ArgumentError)
    end
    
    it 'should require an options hash' do
      lambda { @class.new }.should.raise(ArgumentError)      
    end
    
    it 'should return a verbose parser if the verbose option is set' do
      @class.new(:verbose => true).verbose?.should.be.true
    end
    
    it 'should return a non-verbose parser if the verbose option is false' do
      @class.new(:verbose => false).verbose?.should.be.false
    end
    
    it 'should return a non-verbose parser if the verbose option is missing' do
      @class.new({}).verbose?.should.be.false
    end
    
    it 'should make any passed URL available from the parser' do
      @class.new(:url => 'http://www.domain.com/').url.should == 'http://www.domain.com/'
    end
    
    it 'should make any passed cache path available from the parser' do
      @class.new(:cache => '/tmp/cache').cache.should == '/tmp/cache'
    end
  end
  
  describe 'when looking up the source document' do
    before do
      @document = 'Test Document'
      @parser.stub!(:fetch).and_return(@document)
    end
    
    it 'should work without arguments' do
      lambda { @parser.document }.should.not.raise(ArgumentError)
    end
    
    it 'should not allow arguments' do
      lambda { @parser.document(:foo) }.should.raise(ArgumentError)
    end
    
    it 'should fetch the document on the first try' do
      @parser.should.receive(:fetch)
      @parser.document
    end
    
    it 'should return the fetched document' do
      @parser.document.should == @document
    end
    
    it 'should not fetch the document after the first time' do
      @parser.document
      @parser.should.not.receive(:fetch)
      @parser.document
    end
    
    it 'should return the same document after the first time' do
      result = @parser.document
      @parser.document.should == result
    end
  end
  
  describe 'when processing a data source' do
    before do
      @output = 'Test Output'
      @result = 'Test Upload Result'
      @parser.stub!(:to_output).and_return(@output)
      @parser.stub!(:write!).with(@output).and_return(@result)
    end
    
    it 'should work without arguments' do
      lambda { @parser.process! }.should.not.raise(ArgumentError)
    end
    
    it 'should not allow arguments' do
      lambda { @parser.process!(:foo) }.should.raise(ArgumentError)
    end
    
    it 'should generate the output' do
      @parser.should.receive(:to_output).and_return(@output)
      @parser.process!
    end
    
    it 'should fail if generating the output fails' do
      @parser.stub!(:to_output).and_raise(RuntimeError)
      lambda { @parser.process! }.should.raise(RuntimeError)
    end
    
    it 'should write the generated output' do
      @parser.should.receive(:write!).with(@output)
      @parser.process!
    end

    it 'should fail if writing the generated output fails' do
      @parser.stub!(:write!).and_raise(RuntimeError)
      lambda { @parser.process! }.should.raise(RuntimeError)      
    end
    
    it 'should return the results of writing the output' do
      @parser.process!.should == @result
    end
  end
  
  describe 'when writing output' do
    before do
      @data = 'Test Data'
    end
    
    it 'should accept data' do
      lambda { @parser.write!(@data) }.should.not.raise(ArgumentError)
    end
    
    it 'should require data' do
      lambda { @parser.write! }.should.raise(ArgumentError)
    end
    
    # TODO / FIXME
    it 'CURRENTLY returns the passed data' do
      @parser.write!(@data).should == @data
    end
  end
  
  describe 'when generating output' do
    before do
      @data = 'Test Data'
      @converted = 'Test Converted Data'
      @serialized = 'Test Serialized Data'
      @parser.stub!(:from_input).and_return(@data)
      @parser.stub!(:convert).with(@data).and_return(@converted)
      @parser.stub!(:serialize).with(@converted).and_return(@serialized)
    end
    
    it 'should work without arguments' do
      lambda { @parser.to_output }.should.not.raise(ArgumentError)
    end
    
    it 'should not allow arguments' do
      lambda { @parser.to_output(:foo) }.should.raise(ArgumentError)
    end
    
    it 'should parse the input' do
      @parser.should.receive(:from_input).and_return(@data)
      @parser.to_output
    end
    
    it 'should fail if parsing the input fails' do
      @parser.stub!(:from_input).and_raise(RuntimeError)
      lambda { @parser.to_output }.should.raise(RuntimeError)
    end

    it 'should convert the parsed input' do
      @parser.should.receive(:convert).with(@data).and_return(@converted)
      @parser.to_output
    end
    
    it 'should fail if converting the parsed input fails' do
      @parser.stub!(:convert).and_raise(RuntimeError)
      lambda { @parser.to_output }.should.raise(RuntimeError)
    end

    it 'should serialize the converted input' do
      @parser.should.receive(:serialize).with(@converted).and_return(@serialized)
      @parser.to_output
    end
    
    it 'should fail if serializing the converted input fails' do
      @parser.stub!(:serialize).and_raise(RuntimeError)
      lambda { @parser.to_output }.should.raise(RuntimeError)
    end
    
    it 'should return the results of serializing the converted input' do
      @parser.to_output.should == @serialized
    end
  end
  
  describe 'when parsing input' do
    before do
      @document = 'Test Document'
      @deserialized = 'Test Deserialized Document'
      @parser.stub!(:document).and_return(@document)
      @parser.stub!(:deserialize).with(@document).and_return(@deserialized)
    end
    
    it 'should work without arguments' do
      lambda { @parser.from_input }.should.not.raise(ArgumentError)
    end
    
    it 'should not allow arguments' do
      lambda { @parser.from_input(:foo) }.should.raise(ArgumentError)
    end
    
    it 'should generate the output' do
      @parser.should.receive(:document).and_return(@document)
      @parser.from_input
    end
    
    it 'should fail if generating the output fails' do
      @parser.stub!(:document).and_raise(RuntimeError)
      lambda { @parser.from_input }.should.raise(RuntimeError)
    end
    
    it 'should deserialize the generated output' do
      @parser.should.receive(:deserialize).with(@document)
      @parser.from_input
    end

    it 'should fail if deserializing the generated output fails' do
      @parser.stub!(:deserialize).and_raise(RuntimeError)
      lambda { @parser.from_input }.should.raise(RuntimeError)      
    end
    
    it 'should return the results of deserializing the output' do
      @parser.from_input.should == @deserialized
    end
  end
  
  describe 'when fetching a document' do
    before do
      @url = 'http://test.domain.com/test.url'
      @data = 'Test Downloaded Data'
      @saved = 'Test Saved Status'
      @cached = 'Test Cached Data'
      @parser.stub!(:url).and_return(@url)
      @parser.stub!(:read).with(@url).and_return(@data)
      @parser.stub!(:save).with(@data).and_return(@saved)
      @parser.stub!(:cached).and_return(@cached)
      STDERR.stub!(:puts) # to squelch #verbose? output
    end
    
    it 'should work without arguments' do
      lambda { @parser.fetch }.should.not.raise(ArgumentError)
    end
    
    it 'should not allow arguments' do
      lambda { @parser.fetch(:foo) }.should.raise(ArgumentError)
    end
    
    it 'should look up the url' do
      @parser.should.receive(:url).and_return(@url)
      @parser.fetch
    end
    
    it 'should download data from the url' do
      @parser.should.receive(:read).with(@url).and_return(@data)
      @parser.fetch
    end
    
    it 'should save the downloaded data' do
      @parser.should.receive(:save).with(@data).and_return(@saved)
      @parser.fetch
    end
    
    it 'should not fail if looking up the url fails' do
      @parser.stub!(:url).and_raise(RuntimeError)
      lambda { @parser.fetch }.should.not.raise(RuntimeError)
    end
    
    it 'should return the results of reading from the cache if looking up the url fails' do
      @parser.stub!(:url).and_raise(RuntimeError)
      @parser.fetch.should == @cached
    end

    it 'should not fail if downloading data from the url fails' do
      @parser.stub!(:read).and_raise(RuntimeError)
      lambda { @parser.fetch }.should.not.raise(RuntimeError)
    end

    it 'should return the results of reading from the cache if downloading data from the url fails' do
      @parser.stub!(:read).and_raise(RuntimeError)
      @parser.fetch.should == @cached
    end

    it 'should not fail if saving the downloaded data fails' do
      @parser.stub!(:save).and_raise(RuntimeError)
      lambda { @parser.fetch }.should.not.raise(RuntimeError)
    end
        
    it 'should return the results of reading from the cache if saving the downloaded data fails' do
      @parser.stub!(:save).and_raise(RuntimeError)
      @parser.fetch.should == @cached
    end

    it 'should fail if looking up the url fails and retrieving from the cache fails' do
      @parser.stub!(:url).and_raise(RuntimeError)
      @parser.stub!(:cached).and_raise(RuntimeError)
      lambda { @parser.fetch }.should.raise(RuntimeError)
    end

    it 'should fail if downloading data from the url fails and retrieving from the cache fails' do
      @parser.stub!(:read).and_raise(RuntimeError)
      @parser.stub!(:cached).and_raise(RuntimeError)
      lambda { @parser.fetch }.should.raise(RuntimeError)
    end

    it 'should fail if saving the downloaded data fails and retrieving from the cache fails' do
      @parser.stub!(:save).and_raise(RuntimeError)
      @parser.stub!(:cached).and_raise(RuntimeError)
      lambda { @parser.fetch }.should.raise(RuntimeError)
    end
        
    it 'should return the results of saving the downloaded' do
      @parser.fetch.should == @saved
    end
  end
  
  describe 'when reading data from an URL' do
    before do
      @url = 'http://test.domain.com/test.url'
      @parser.stub!(:open).with(@url).and_return(@data)
    end
    
    it 'should accept an URL' do
      lambda { @parser.read(@url) }.should.not.raise(ArgumentError)
    end
    
    it 'should require an URL' do
      lambda { @parser.read }.should.raise(ArgumentError)
    end
    
    it 'should open the URL' do
      @parser.should.receive(:open).with(@url).and_return(@data)
      @parser.read(@url)
    end
    
    it 'should fail if opening the URL fails' do
      @parser.stub!(:open).and_raise(RuntimeError)
      lambda { @parser.read(@url) }.should.raise(RuntimeError)
    end
    
    it 'should return the result of opening and reading the URL data' do
      @parser.read(@url).should == @data
    end
  end
  
  describe 'when saving a cached copy of file data' do
    before do
      @data = 'Test Data'
      @file = 'Test Cache File'
      @parser.stub!(:cache_file).and_return(@file)
      File.stub!(:open).with(@file, 'w')
      STDERR.stub!(:puts)
    end
    
    it 'should accept data' do
      lambda { @parser.save(@data) }.should.not.raise(ArgumentError)
    end
    
    it 'should require data' do
      lambda { @parser.save }.should.raise(ArgumentError)
    end
    
    it 'should open the cache file for writing' do
      File.should.receive(:open).with(@file, 'w')
      @parser.save(@data)
    end
    
    it 'should not fail if writing the cache file fails' do
      File.stub!(:open).and_raise(RuntimeError)
      lambda { @parser.save(@data) }.should.not.raise(RuntimeError)
    end
    
    it 'should return the passed data if writing the cache file fails' do
      File.stub!(:open).and_raise(RuntimeError)
      @parser.save(@data).should == @data
    end
    
    it 'should return the passed data if writing the cache file succeeds' do
      @parser.save(@data).should == @data
    end
  end

  describe 'when reading cached file data' do
    before do
      @data = 'Test Data'
      @file = 'Test Cache File'
      @parser.stub!(:cache_file).and_return(@file)
      File.stub!(:read).with(@file).and_return(@data)
    end
    
    it 'should work without arguments' do
      lambda { @parser.cached }.should.not.raise(ArgumentError)
    end
    
    it 'should not allow arguments' do
      lambda { @parser.cached(:foo) }.should.raise(ArgumentError)
    end
    
    it 'should read the cache file' do
      File.should.receive(:read).with(@file)
      @parser.cached
    end
    
    it 'should fail if reading the cache file fails' do
      File.stub!(:read).and_raise(RuntimeError)
      lambda { @parser.cached }.should.raise(RuntimeError)
    end
    
    it 'should return data read from the cache file' do
      @parser.cached.should == @data
    end
  end
  
  describe 'when looking up the path to the cache directory' do
    it 'should return any path provided at initialization' do
      @class.new(:cache => '/tmp/foo').cache.should == '/tmp/foo'
    end
    
    it 'should return the path to an in-app cache directory if no path was specified at initialization' do
      @class.new({}).cache.should == File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. cache]))
    end
  end
  
  describe 'when finding a filename for our URL' do
    before do
      @url = 'https://user:pass@test.domain.com:443/path/to/something.txt?a=b&c=d#anchor'
      @parser.stub!(:url).and_return(@url)
    end
    
    it 'should work without arguments' do
      lambda { @parser.filename }.should.not.raise(ArgumentError)
    end
    
    it 'should not allow arguments' do
      lambda { @parser.filename(:foo) }.should.raise(ArgumentError)
    end
    
    it 'should return the file component of our URL' do
      @parser.filename.should == 'something.txt'
    end
    
    it 'should fail when given a bad URL' do
      @parser.stub!(:url).and_return('::::::')
      lambda { @parser.filename }.should.raise(URI::InvalidURIError)
    end
  end
  
  describe 'when looking up the cache file for our URL' do
    before do
      @file = 'catalog.xml'
      @cache = '/tmp'
      @parser.stub!(:filename).and_return(@file)
      @parser.stub!(:cache).and_return(@cache)
    end
    
    it 'should work without arguments' do
      lambda { @parser.cache_file }.should.not.raise(ArgumentError)
    end
    
    it 'should not allow arguments' do
      lambda { @parser.cache_file(:foo) }.should.raise(ArgumentError)
    end
    
    it 'should return the location of the URL file inside the cache path' do
      @parser.cache_file.should == File.join(@cache, @file)
    end
  end
  
  describe 'when converting a document from XML' do
    before do
      @document = 'Test Document'
      @parsed = 'Test Parsed Document'
      Nokogiri::XML.stub!(:parse).with(@document).and_return(@parsed)
    end
    
    it 'should allow a document' do
      lambda { @parser.from_xml(@document) }.should.not.raise(ArgumentError)
    end
    
    it 'should require a document' do
      lambda { @parser.from_xml }.should.raise(ArgumentError)
    end
    
    it 'should parse the XML file' do
      Nokogiri::XML.should.receive(:parse).with(@document).and_return(@parsed)
      @parser.from_xml(@document)
    end
    
    it 'should fail if parsing the XML fails' do
      Nokogiri::XML.stub!(:parse).and_raise(RuntimeError)
      lambda { @parser.from_xml(@document) }.should.raise(RuntimeError)
    end
    
    it 'should return the result of parsing the XML file' do
      @parser.from_xml(@document).should == @parsed
    end
  end

  describe 'when producing a list of destination attribute names' do
    before do
      @parser.stub!(:conversion_map).and_return([])
    end
    
    it 'should work without arguments' do
      lambda { @parser.destinations }.should.not.raise(ArgumentError)
    end
    
    it 'should not allow arguments' do
      lambda { @parser.destinations(:foo) }.should.raise(ArgumentError)
    end
    
    it 'should fail if retrieving the conversion map fails' do
      @parser.stub!(:conversion_map).and_raise(RuntimeError)
      lambda { @parser.destinations }.should.raise(RuntimeError)
    end

    it 'should return an empty list when the conversion map is empty' do
      @parser.stub!(:conversion_map).and_return([])
      @parser.destinations.should == []
    end
    
    it 'should return a list of the first elements of the conversion map' do
      @parser.stub!(:conversion_map).and_return([ [ 'foo', 'bar' ], [ 'baz', 'xyzzy' ] ])
      @parser.destinations.should == [ 'foo', 'baz' ]
    end
  end

  describe 'when changing a single row based upon a rule' do
    it 'should accept a rule and a row' do
      lambda { @parser.change('rule', 'row') }.should.not.raise(ArgumentError)
    end
    
    it 'should require a rule and a row' do
      lambda { @parser.change('rule') }.should.raise(ArgumentError)
    end
    
    it 'should return the value of the named field from the row if the rule is a string' do
      @parser.change('field', { 'foo' => 'bar', 'field' => 'day'}).should == 'day'
    end
    
    it 'should return the result of calling the rule on the row if the rule is callable' do
      rule = Proc.new {|row| row.keys.size }
      @parser.change(rule, { 'a' => 'b', 'c' => 'd', 'e' => 'f'}).should == 3
    end
    
    it 'should fail if calling a callable rule fails' do
      rule = Proc.new {|row| raise "Flunk!" }
      lambda { @parser.change(rule, { 'a' => 'b', 'c' => 'd', 'e' => 'f'}) }.should.raise(RuntimeError)
    end
  end
  
  describe 'when converting the conversion map pairing into a hash' do
    before do
      @parser.stub!(:conversion_map).and_return([])
    end
    
    it 'should work without arguments' do
      lambda { @parser.mapping }.should.not.raise(ArgumentError)
    end
    
    it 'should not allow arguments' do
      lambda { @parser.mapping(:foo) }.should.raise(ArgumentError)
    end
    
    it 'should fail if looking up the conversion map fails' do
      @parser.stub!(:conversion_map).and_raise(RuntimeError)
      lambda { @parser.mapping }.should.raise(RuntimeError)
    end    
    
    it 'should map each paired conversion map entry to a hash key-value pair' do
      @parser.stub!(:conversion_map).and_return([[1, 2], [3, 4], [4, 5]])
      @parser.mapping.should == { 1 => 2, 3 => 4, 4 => 5}
    end
  end
end


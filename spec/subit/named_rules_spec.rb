require 'spec_helper'

describe Subit::NamedRules do
  before do
    @named_rules = Subit::NamedRules.new
  end
  
  it ".new(:name => 'foo') shoudl set name" do
    named_rules = Subit::NamedRules.new(:name => 'foo')
    named_rules.name.should == 'foo'
  end
  
  it "#define(*names, &block) should create configurator on self" do
    Subit::Configurator.should_receive(:new).with(@named_rules).and_return(conf = mock)
    conf.should_receive(:define).with('one', 'two')
    @named_rules.define('one', 'two') {}
  end
  
  it "#define should return self" do
    @named_rules.define(){}.should == @named_rules
  end
  
  describe '#add names' do
    it "calls #sanitize_names!" do
      @named_rules.should_receive(:sanitize_names!).with(['one', :two])
      @named_rules.add ['one', :two]
    end
    
    it "#sanitize_names!(ary) make names uniq, sorted, string array" do
      names = ['c', :b, 'a', 'b', :a]
      @named_rules.instance_eval { sanitize_names!(names) }.should == ['a', 'b', 'c']
      names.should == ['a', 'b', 'c']
    end
    
    it "creates a Rules object if it doesn't exist" do
      Subit::Rules.should_receive(:new).and_return(rules = mock)
      @named_rules.add([]).should == rules
      @named_rules.to_hash.should == {[] => rules}
    end
    
    it "returns existing Rules object if it does exist" do
      rules = @named_rules.add([:b, :a])
      @named_rules['a', 'b'].should == rules
      @named_rules.to_hash.should == {['a', 'b'] => rules}
    end
  end
  
  describe 'parsing' do
    describe "with :html, :metric, [:html, :metric], and root rules" do
      before do
        @root_rules = @named_rules.add([])
        @html_rules = @named_rules.add([:html])
        @metric_rules = @named_rules.add([:metric])
        @html_metric_rules = @named_rules.add([:html, :metric])
      end
    
      it "#parse should parse using root rules" do
        @root_rules.should_receive(:parse).with('start', :names => []).and_return('root')
        @named_rules.parse('start').should == 'root'
      end
      
      it "#parse(..., :html) should parse using root rules, then :html rules" do
        @root_rules.should_receive(:parse).with('start', :names => ['html']).and_return('root')
        @html_rules.should_receive(:parse).with('root', :names => ['html']).and_return('html')
        @named_rules.parse('start', :html).should == 'html'
      end
            
      it "#parse(..., :metric, :html) should parse using all rules in order" do
        @root_rules.should_receive(:parse).with('start', :names => ['html', 'metric']).and_return('root')
        @html_rules.should_receive(:parse).with('root', :names => ['html', 'metric']).and_return('html')
        @metric_rules.should_receive(:parse).with('html', :names => ['html', 'metric']).and_return('metric')
        @html_metric_rules.should_receive(:parse).with('metric', :names => ['html', 'metric']).and_return('html metric')
        @named_rules.parse('start', :metric, :html).should == 'html metric'
      end
      
      it "#parse_with_parse_original!(...) should parse_with_parse_original! on root rules" do
        @root_rules.should_receive(:parse_with_parse_original!).with('start', :names => [], :parsed => 'start').and_return('root')
        @named_rules.parse_with_parse_original!('start').should == 'root'
      end
    end
  end

  describe '+' do
    before do
      @nr1 = Subit::NamedRules.new.define(:html) { rule 'a', 'b' }
      @nr2 = Subit::NamedRules.new.define() { rule 'c', 'd'; define(:html) { rule 'e', 'f' } }
      @addition = @nr1 + @nr2
    end
    
    it "should coallesce rules" do
      @addition[:html].should == @nr1[:html] + @nr2[:html]
      @addition.keys.should == [['html'], []]
      @addition[].should == @nr2[]
    end
    
    it "should transfer exec of all rules to new named_rules" do
      rules = @addition.values.flatten
      rules[0].exec.should == @addition
      rules[1].exec.should == @addition
      rules[2].exec.should == @addition
    end
    
    it "should transfer included modules to new named_rules" do
      mixin1 = Module.new
      mixin2 = Module.new
      @nr1.singleton_class.send :include, mixin1
      @nr2.singleton_class.send :include, mixin2
      @addition = @nr1 + @nr2
      @addition.singleton_class.included_modules.should include(mixin1, mixin2)
    end
  end
end
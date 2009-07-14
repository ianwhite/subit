require File.dirname(__FILE__) + '/spec_helper'

describe Subit::NamedRules do
  before do
    @named_rules = Subit::NamedRules.new
  end
  
  describe '#add_rules names' do
    it "calls #sanitize_names" do
      @named_rules.should_receive(:sanitize_names).with(['one', :two])
      @named_rules.add_rules ['one', :two]
    end
    
    it "#sanitize_names(ary) should return uniq, sorted, string array" do
      @named_rules.instance_eval { sanitize_names(['c', :b, 'a', 'b', :a]) }.should == ['a', 'b', 'c']
    end
    
    it "creates a Rules object if it doesn't exist" do
      Subit::Rules.should_receive(:new).and_return(rules = mock)
      @named_rules.add_rules([]).should == rules
      @named_rules.should == {[] => rules}
    end
    
    it "returns existing Rules object if it does exist" do
      rules = @named_rules.add_rules([:b, :a])
      @named_rules['a', 'b'].should == rules
      @named_rules.should == {['a', 'b'] => rules}
    end
  end
  
  describe 'parsing' do
    describe "with :html, :metric, [:html, :metric], and root rules" do
      before do
        @root_rules = @named_rules.add_rules([])
        @html_rules = @named_rules.add_rules([:html])
        @metric_rules = @named_rules.add_rules([:metric])
        @html_metric_rules = @named_rules.add_rules([:html, :metric])
      end
    
      it "#parse should parse using root rules" do
        @root_rules.should_receive(:parse).with('start', :names => []).and_return('root')
        @named_rules.parse('start').should == 'root'
      end
      
      it "#parse(..., :html) should parse using root rules, and :html rules" do
        @root_rules.should_receive(:parse).with('start', :names => ['html']).and_return('root')
        @html_rules.should_receive(:parse).with('root', :names => ['html']).and_return('html')
        @named_rules.parse('start', :html).should == 'html'
      end
            
      it "#parse('..., :metric, :html) should parse using all rules" do
        @root_rules.should_receive(:parse).with('start', :names => ['html', 'metric']).and_return('root')
        @html_rules.should_receive(:parse).with('root', :names => ['html', 'metric']).and_return('html')
        @html_metric_rules.should_receive(:parse).with('html', :names => ['html', 'metric']).and_return('html metric')
        @metric_rules.should_receive(:parse).with('html metric', :names => ['html', 'metric']).and_return('metric')
        @named_rules.parse('start', :metric, :html).should == 'metric'
      end
    end
  end
end
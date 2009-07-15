require File.dirname(__FILE__) + '/spec_helper'

describe Subit::Rules do
  before do
    @rules = Subit::Rules.new
  end
  
  describe "#add" do
    it "when first arg is a rule (determined by #rule?), concat" do
      @rules.should_receive(:rule?).with(rule = mock).and_return(true)
      @rules.should_receive(:<<).with(rule)
      @rules.add rule
    end
    
    it "when first arg has a rule_class, create using klass, and remaining args, concat" do
      @rules.should_receive(:rule_class).with(:foo).and_return(rule_class = mock)
      rule_class.should_receive(:new).with(:second, :third).and_return(rule = mock)
      @rules.should_receive(:<<).with(rule)
      @rules.add :foo, :second, :third
    end
    
    it "when first arg has no associated rule_class, raise an ArgumentError" do
      @rules.should_receive(:rule_class).with(:foo).and_return(false)
      lambda { @rules.add :foo }.should raise_error(ArgumentError)
    end
  end
  
  it "#can_add_rule? should return false if argument is neither a rule symbol nor a rule object" do
    @rules.should_receive(:rule?).with('foo').and_return(false)
    @rules.should_receive(:rule_class).with('foo').and_return(false)
    @rules.can_add_rule?('foo').should == false
  end
  
  describe "Use case #1" do
    before do
      @content = 'hello & goodbye'
      @rules = Subit::Rules.new
      @rules.add Subit::Rule.new(/[hH]ello/, 'hi')
      @rules.add :rule, '&' do |match|
        'and'
      end
      @rules << Subit::Rule.new(/goodbye/i, :replace => 'bye bye', :original => 'GOODBYE')
    end
    
    it 'should apply all rules with #parse(content)' do
      @rules.parse(@content).should == 'hi and bye bye'
      @content.should == 'hello & goodbye'
    end
  
    it 'should apply all rules and modify original with #parse_with_parse_original!(@content)' do
      @rules.parse_with_parse_original!(@content).should == 'hi and bye bye'
      @content.should == 'hello & GOODBYE'
    end
  end
  
  describe "Use case #2" do
    before do
      @content = 'start'
      @rules = Subit::Rules.new
      @rules.add :rule, 'a', '[a]', :original => 'A'
    end
    
    it "#parse_with_parse_original!(content) should modify content using :original rules" do
      @rules.parse_with_parse_original!(@content).should == 'st[a]rt'
      @content.should == 'stArt'
    end

    describe "(and a rule based on options)" do
      before do
        @rules.add :rule, 't', '[t]', :original => lambda {|match, options| options[:upcase_t] ? 'T' : match}
      end
      
      it "#parse_with_parse_original!(content) should modify content using original rules" do
        @rules.parse_with_parse_original!(@content).should == 's[t][a]r[t]'
        @content.should == 'stArt'
      end
      
      it "#parse_with_parse_original!(content, <options>) should modify content using options" do
        @rules.parse_with_parse_original!(@content, :upcase_t => true).should == 's[t][a]r[t]'
        @content.should == 'sTArT'
      end
    end
  end
  
  describe "+" do
    before do
      @r1 = Subit::Rules.new
      @r1 << (@rule1 = Subit::Rule.new('a'))
      @r2 = Subit::Rules.new
      @r2 << (@rule2 = Subit::Rule.new('b'))
      @add = @r1 + @r2
    end
    
    it "should be a Rules object" do
      @add.should be_a(Subit::Rules)
    end
    
    it "should concat elements" do
      @add.to_a.should == [@rule1, @rule2]
    end
    
    it "should be new object" do
      @add.object_id.should_not == @r1.object_id
      @add.object_id.should_not == @r2.object_id
    end
  end
end
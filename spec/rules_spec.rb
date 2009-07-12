require File.dirname(__FILE__) + '/spec_helper'

describe Subit::Rules do
  before do
    @rules = Subit::Rules.new
  end
  
  describe "#method_missing" do
    it "forwards rule symbols to #add" do
      @rules.should_receive(:rule_class).with(:foo).and_return(true)
      @rules.should_receive(:add).with(:foo, :bar)
      @rules.foo :bar
    end
  
    it "forwards NON rule symbols to super #method_missing" do
      @rules.should_receive(:rule_class).with(:foo).and_return(false)
      @rules.should_not_receive(:add)
      lambda { @rules.foo :bar }.should raise_error(NoMethodError)
    end
  end
  
  describe "#add" do
    it "when first arg is a rule (determined by #rule?), concat to #rules" do
      @rules.should_receive(:rule?).with(rule = mock).and_return(true)
      @rules.rules.should_receive(:<<).with(rule)
      @rules.add rule
    end
    
    it "when first arg has a rule_class, create using klass, and remaining args, concat to #rules" do
      @rules.should_receive(:rule_class).with(:foo).and_return(rule_class = mock)
      rule_class.should_receive(:new).with(:second, :third).and_return(rule = mock)
      @rules.rules.should_receive(:<<).with(rule)
      @rules.add :foo, :second, :third
    end
    
    it "when first arg has no associated rule_class, raise an ArgumentError" do
      @rules.should_receive(:rule_class).with(:foo).and_return(false)
      lambda { @rules.add :foo }.should raise_error(ArgumentError)
    end
  end
  
  describe "Use case" do
    before do
      @content = 'hello & goodbye'
    end
    
    describe "rules use case", :shared => true do
      it 'should apply all rules with #parse(content)' do
        @rules.parse(@content).should == 'hi and bye bye'
        @content.should == 'hello & goodbye'
      end
    
      it 'should apply all rules and modify original with #parse!(@content)' do
        @rules.parse!(@content).should == 'hi and bye bye'
        @content.should == 'hello & GOODBYE'
      end
    end
  
    describe "created via block" do
      before do
        @rules = Subit::Rules.new do
          rule /[hH]ello/, 'hi'
          rule '&' do |match|
            'and'
          end
          rule /goodbye/i, :replace => 'bye bye', :original => 'GOODBYE'
        end
      end
      
      it_should_behave_like "rules use case"
    end
    
    describe "created via #add" do
      before do
        @rules = Subit::Rules.new
        @rules.add :rule, /[hH]ello/, 'hi'
        @rules.add :rule, '&' do |match|
          'and'
        end
        @rules.add Subit::Rule.new(/goodbye/i, :replace => 'bye bye', :original => 'GOODBYE')
      end
      
      it_should_behave_like "rules use case"
    end
  end
end
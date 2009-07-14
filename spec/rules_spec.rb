require File.dirname(__FILE__) + '/spec_helper'

describe Subit::Rules do
  before do
    @rules = Subit::Rules.new
  end
  
  describe "#add_rule" do
    it "when first arg is a rule (determined by #rule?), concat" do
      @rules.should_receive(:rule?).with(rule = mock).and_return(true)
      @rules.should_receive(:<<).with(rule)
      @rules.add_rule rule
    end
    
    it "when first arg has a rule_class, create using klass, and remaining args, concat" do
      @rules.should_receive(:rule_class).with(:foo).and_return(rule_class = mock)
      rule_class.should_receive(:new).with(:second, :third).and_return(rule = mock)
      @rules.should_receive(:<<).with(rule)
      @rules.add_rule :foo, :second, :third
    end
    
    it "when first arg has no associated rule_class, raise an ArgumentError" do
      @rules.should_receive(:rule_class).with(:foo).and_return(false)
      lambda { @rules.add_rule :foo }.should raise_error(ArgumentError)
    end
  end
  
  describe "Use case" do
    before do
      @rules = Subit::Rules.new
      @rules.add_rule Subit::Rule.new(/[hH]ello/, 'hi')
      @rules.add_rule :rule, '&' do |match|
        'and'
      end
      @rules << Subit::Rule.new(/goodbye/i, :replace => 'bye bye', :original => 'GOODBYE')

      @content = 'hello & goodbye'
    end
    
    it 'should apply all rules with #parse(content)' do
      @rules.parse(@content).should == 'hi and bye bye'
      @content.should == 'hello & goodbye'
    end
  
    it 'should apply all rules and modify original with #parse!(@content)' do
      @rules.parse!(@content).should == 'hi and bye bye'
      @content.should == 'hello & GOODBYE'
    end
  end
end
require File.dirname(__FILE__) + '/spec_helper'

describe Subit::Configurator do
  it ".new(named_rules) should store the named_rules object" do
    @conf = Subit::Configurator.new(nr = Subit::NamedRules.new)
    @conf.named_rules.should == nr
  end
  
  it ".new() should create a NamedRules object on demand" do
    Subit::Configurator.new.named_rules.should be_a(Subit::NamedRules)
  end
    
  describe "on a NamedRules" do
    before do
      @named_rules = Subit::NamedRules.new
      @conf = Subit::Configurator.new(@named_rules)
    end
    
    it "should delegate rule_class to Subit" do
      Subit.should_receive(:rule_class).with('foo').and_return(rule_class = mock)
      @conf.rule_class('foo').should == rule_class
    end
    
    it "define(&block) call with_names([])" do
      @conf.should_receive(:with_names).with([])
      @conf.define() {}
    end

    it "define(&block) should eval block in conf instance" do
      block = lambda { in_block }
      @conf.should_receive(:in_block)
      @conf.define(&block)
    end
    
    it "define(&block) should create a new Rules object on named rules" do
      Subit::Rules.should_receive(:new).and_return(rules = mock)
      @conf.define() {}
      @conf.named_rules[].should == rules
    end
    
    it "define(&block) should not create a rules object if it exists" do
      @conf.define() {}
      rules = @conf.named_rules[]
      Subit::Rules.should_not_receive(:new)
      @conf.define() {}
      @conf.named_rules[].should == rules
    end
    
    it "define() { define :one { define :two {}}} should create [], ['one'], and ['one', 'two'] Rules" do
      @conf.define() { define(:one) { define(:two) {}}}
      @conf.named_rules.keys.sort.should == [[], ['one'], ['one', 'two']]
    end
  end
end
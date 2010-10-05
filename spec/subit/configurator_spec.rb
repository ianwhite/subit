require 'spec_helper'

describe Subit::Configurator do
  it ".new(named_rules) should store the named_rules object" do
    @conf = Subit::Configurator.new(nr = Subit::NamedRules.new)
    @conf.named_rules.should == nr
  end
  
  it ".new() should create a NamedRules object on demand" do
    Subit::Configurator.new.named_rules.should be_a(Subit::NamedRules)
  end
  
  it "#define() should return the named_rules object" do
    @conf = Subit::Configurator.new
    @conf.define(){}.should == @conf.named_rules
  end
  
  describe "on a NamedRules" do
    before do
      @named_rules = Subit::NamedRules.new
      @conf = Subit::Configurator.new(@named_rules)
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
      rules = @conf.define(){}
      Subit::Rules.should_not_receive(:new)
      @conf.define(){}.should == rules
    end
    
    it "#current_rules returns current rules object" do
      @conf.instance_eval { @current_names = ['one', 'two']}
      @conf.named_rules.should_receive(:[]).with(['one', 'two']).and_return(rules = mock)
      @conf.instance_eval { current_rules }.should == rules
    end
    
    describe "define() { define(:one) { define(:two) {}}; define(:zap) {}; define('one') {}}" do
      before do
        @conf.define do 
          define :one do
            define :two do
            end
          end
          define :zap do
          end
          define 'one' do
          end
        end
      end
      
      it "should create [], ['one'], ['one', 'two'], ['zap'] Rules" do
        @conf.named_rules.keys.sort.should == [[], ['one'], ['one', 'two'], ['zap']]
      end
    end
    
    it "should respond_to methods that can be added to current rules object" do
      @conf.should_not respond_to('foo')
      @conf.stub(:current_rules).and_return(mock)
      @conf.current_rules.should_receive(:can_add_rule?).with(:foo).and_return(true)
      @conf.should respond_to(:foo)
    end
    
    it "should forward missing methods that can be added to current_rules object" do
      @conf.stub(:current_rules).and_return(mock)
      @conf.current_rules.should_receive(:can_add_rule?).with(:foo).and_return(true)
      @conf.current_rules.should_receive('add').with(:foo, 'one', 'two', :exec => @conf.named_rules)
      @conf.foo 'one', 'two'
    end
    
    it "should raise NoMethodError on unknown rules" do
      lambda {@conf.foo }.should raise_error(NoMethodError)
    end
    
    describe "define() { rule('a', 'b'); define(:html) { rule('c'){ 'd' } } }" do
      before do
        d_block = @d_block = lambda { 'd' }
        
        @conf.define do
          rule 'a', 'b'
          define :html do
            rule 'c', &d_block
          end
        end
      end
      
      it "should create two rules objects [], and ['html']" do
        @conf.named_rules.keys.sort.should == [[], ['html']]
      end
      
      it "named_rules[] should have an a/b rule" do
        @conf.named_rules[].length.should == 1
        @conf.named_rules[].first.search.should == 'a'
        @conf.named_rules[].first.replacement.should == 'b'
      end
      
      it "named_rules[:html] should have an c/d_block rule" do
        @conf.named_rules[:html].length.should == 1
        @conf.named_rules[:html].first.search.should == 'c'
        @conf.named_rules[:html].first.replacement.should == @d_block
      end
      
      it "the rules should have exec of the named_rules object" do
        @conf.named_rules[].first.exec.should == @conf.named_rules
        @conf.named_rules[:html].first.exec.should == @conf.named_rules
      end
    end
    
    describe "define() { add <rule> }" do
      before do
        @rule = rule = Subit::Rule.new('a', 'b')
        
        @conf.define() do
          add rule
        end
      end
      
      it "named_rules[] should contain <rule>" do
        @conf.named_rules[].to_a.should == [@rule]
      end
      
      it "the rules should have exec of the named_rules object" do
        @conf.named_rules[].first.exec.should == @conf.named_rules
      end
    end
  end
end
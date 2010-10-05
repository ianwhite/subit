require 'spec_helper'

describe "@content is 'I search and search', " do
  before do
    @content = 'I search and search'
  end
  
  describe Subit::Rule do
    describe ".new('search')" do
      before do
        @rule = Subit::Rule.new 'search'
      end
    
      it "#parse(@content) should return 'I  and ', but not modify @content" do
        @rule.parse(@content).should == 'I  and '
        @content.should == 'I search and search'
      end
    
      it "#parse!(@content) should return and modify @content to be 'I  and '" do
        @rule.parse!(@content).should == 'I  and '
        @content.should == 'I  and '
      end
    end
    
    describe "Rule with search: /([ae])/, replace: '[\\1]'", :shared => true do
      it "#parse(@content) should return 'I s[e][a]rch [a]nd s[e][a]rch', and not modify @content" do
        @rule.parse(@content).should == 'I s[e][a]rch [a]nd s[e][a]rch'
        @content.should == 'I search and search'
      end
      
      it "#parse!(@content) should return and modify @content to be 'I s[e][a]rch [a]nd s[e][a]rch'" do
        @rule.parse!(@content).should == 'I s[e][a]rch [a]nd s[e][a]rch'
        @content.should == 'I s[e][a]rch [a]nd s[e][a]rch'
      end
    end
    
    describe ".new(/([ae])/, '[\\1]')" do
      before { @rule = Subit::Rule.new(/([ae])/, "[\\1]") }
      it_should_behave_like "Rule with search: /([ae])/, replace: '[\\1]'"
    end
    
    describe ".new(/([ae])/, :replace => '[\\1]')" do
      before { @rule = Subit::Rule.new(/([ae])/, :replace => '[\\1]') }
      it_should_behave_like "Rule with search: /([ae])/, replace: '[\\1]'"
    end
    
    describe ".new(/([ae])/, :replace => lambda {|i| \"[\#{i}]\"})" do
      before { @rule = Subit::Rule.new(/([ae])/, :replace => lambda {|i| "[#{i}]"}) }
      it_should_behave_like "Rule with search: /([ae])/, replace: '[\\1]'"
    end
    
    describe ".new(/([ae])/) {|i| \"[\#{i}]\"}" do
      before { @rule = Subit::Rule.new(/([ae])/) {|i| "[#{i}]"} }
      it_should_behave_like "Rule with search: /([ae])/, replace: '[\\1]'"
    end
    
    describe "execution context" do
      it "can be set on a rule" do
        rule = Subit::Rule.new('search', :exec => "foo", :replace => "replace")
        rule.exec.should == "foo"
      end
      
      it "when set on a rule, block is executed within that context" do
        rule = Subit::Rule.new('search', :exec => "foo") { self == "foo" ? "IS FOO" : "FAIL" }
        rule.parse('search').should == "IS FOO"
      end
      
      it "can be overriden by passing parse :exec to parse" do
        rule = Subit::Rule.new('search', :exec => "foo") { self == "foo" ? "IS FOO" : "IS NOT FOO" }
        rule.parse('search', :exec => 'bar').should == "IS NOT FOO"
      end
      
      it "when not set, is the block's execution context'" do
        local_foo = "foo"
        rule = Subit::Rule.new('search') { local_foo }
        rule.parse('search').should == "foo"
      end
    end
    
    describe ".new('search') {|match| raise 'Boom'}" do
      before do
        @rule = Subit::Rule.new('search') {|match| raise 'Boom'}
      end
      
      context "(Subit.raise_parse_errors? is TRUE)" do
        before do
          Subit.stub!(:raise_parse_errors?).and_return(true)
        end
        
        it "#parse(@content) should raise an error" do
          lambda { @rule.parse(@content) }.should raise_error("Boom")
        end
      end
      
      context "(Subit.raise_parse_errors? is FALSE)" do
        before do
          Subit.stub!(:raise_parse_errors?).and_return(false)
        end
        
        it "#parse(@content) send two errors to the logger" do
          Subit.stub!(:logger).and_return(logger = mock)
          logger.should_receive(:error).with("[Subit] #{@rule.inspect} with: #<MatchData \"search\"> got exception: #<RuntimeError: Boom>").twice
          @rule.parse(@content)
        end
      end
    end
  end
end
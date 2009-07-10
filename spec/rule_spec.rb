require File.dirname(__FILE__) + '/spec_helper'

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
    
    describe "Rule with search: /[ae]/, replace: '[$0]'", :shared => true do
      it "#parse(@content) should return 'I s[e][a]rch [a]nd s[e][a]rch', and not modify @content" do
        @rule.parse(@content).should == 'I s[e][a]rch [a]nd s[e][a]rch'
        @content.should == 'I search and search'
      end
      
      it "#parse!(@content) should return and modify @content to be 'I s[e][a]rch [a]nd s[e][a]rch'" do
        @rule.parse!(@content).should == 'I s[e][a]rch [a]nd s[e][a]rch'
        @content.should == 'I s[e][a]rch [a]nd s[e][a]rch'
      end
    end
    
    describe ".new(/[ae]/, '[$0]')" do
      before { @rule = Subit::Rule.new(/[ae]/, '[$0]') }
      it_should_behave_like "Rule with search: /[ae]/, replace: '[$0]'"
    end
    
    describe ".new(/[ae]/, :replace => '[$0]')" do
      before { @rule = Subit::Rule.new(/[ae]/, :replace => '[$0]') }
      it_should_behave_like "Rule with search: /[ae]/, replace: '[$0]'"
    end
    
    describe ".new(/[ae]/, :replace => lambda {|i| \"[\#{i}]\"})" do
      before { @rule = Subit::Rule.new(/[ae]/, :replace => lambda {|i| "[#{i}]"}) }
      it_should_behave_like "Rule with search: /[ae]/, replace: '[$0]'"
    end
    
    describe ".new(/[ae]/) {|i| \"[\#{i}]\"}" do
      before { @rule = Subit::Rule.new(/[ae]/) {|i| "[#{i}]"} }
      it_should_behave_like "Rule with search: /[ae]/, replace: '[$0]'"
    end
    
    describe ".new('search', :replace => '?', :replace! => 'SEARCH')" do
      before do
        @rule = Subit::Rule.new('search', :replace => '?', :replace! => 'SEARCH')
      end
      
      it "#parse(@content) should return 'I ? and ?', but not modify @content" do
        @rule.parse(@content).should == 'I ? and ?'
        @content.should == 'I search and search'
      end
      
      it "#parse!(@content) should return 'I ? and ?', and @content be 'I SEARCH and SEARCH'" do
        @rule.parse!(@content).should == 'I ? and ?'
        @content.should == 'I SEARCH and SEARCH'
      end
    end
    
    describe ".new('search') {|match, options| \"\#{self.class == String ? 'String' : 'NOT'}\#{options[:thing]}\"}" do
      before do
        @rule = Subit::Rule.new('search') {|match, options| "#{self.class == String ? 'String' : 'NOT'}#{options[:thing]}"}
      end
      
      it "#parse(@content) should == 'I NOT and NOT'" do
        @rule.parse(@content).should == "I NOT and NOT"
      end

      it "#parse(@content, :thing => '!') should == 'I NOT! and NOT!'" do
        @rule.parse(@content, :thing => '!').should == "I NOT! and NOT!"
      end
      
      it "#parse(@content, :exec => 'a string') should == 'I String and String'" do
        @rule.parse(@content, :exec => 'a string').should == "I String and String"
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
        
        it "#parse(@content) send two warnings to the logger" do
          Subit.stub!(:logger).and_return(logger = mock)
          logger.should_receive(:warn).with("[Subit] #{@rule.inspect} with: #<MatchData \"search\"> got exception: #<RuntimeError: Boom>").twice
          @rule.parse(@content)
        end
      end
    end
  end
end
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
      before { @rule = Subit::Rule.new('search', :replace => '?', :replace! => 'SEARCH') }
      
      it "#parse(@content) should return 'I ? and ?', but not modify @content" do
        @rule.parse(@content).should == 'I ? and ?'
        @content.should == 'I search and search'
      end
      
      it "#parse!(@content) should return 'I ? and ?', and @content be 'I SEARCH and SEARCH'" do
        @rule.parse!(@content).should == 'I ? and ?'
        @content.should == 'I SEARCH and SEARCH'
      end
    end
  end
end
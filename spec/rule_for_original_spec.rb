require File.dirname(__FILE__) + '/spec_helper'

describe Subit::RuleForOriginal do
  describe ".new('search', :replace => '?', :replace! => 'SEARCH')" do
    before do
      @rule = Subit::Rule.new('search', :replace => '?', :original => 'SEARCH')
    end
    
    describe "@content is 'I search and search', " do
      before do
        @content = 'I search and search'
      end

      it "#parse(@content) should return 'I ? and ?'" do
        @rule.parse(@content).should == 'I ? and ?'
      end
    
      it ".rule_for_original.parse(@content) should return 'I SEARCH and SEARCH'" do
        @rule.rule_for_original.parse(@content).should == 'I SEARCH and SEARCH'
      end
    end
  end
  
  describe "rule creation" do
    it ":original => String should create rule like :replace => String" do
      rule = Subit::Rule.new 'search', :original => 'string'
      rule.rule_for_original.instance_eval do
        @search.should == 'search'
        @replacement.should == 'string'
      end
    end
    
    it ":original => Rule should create new rule like :replace => String" do
      rule = Subit::Rule.new('search', :original => (orig_rule = Subit::Rule.new('foo')))
      rule.rule_for_original.should == orig_rule
    end
  end
end
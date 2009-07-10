require File.dirname(__FILE__) + '/spec_helper'

describe "@content is 'I search and search', " do
  before do
    @content = 'I search and search'
  end
    
  describe ".new('search', :replace => '?', :replace! => 'SEARCH')" do
    before do
      @rule = Subit::Rule.new('search', :replace => '?', :original => 'SEARCH')
    end
    
    it "#parse(@content) should return 'I ? and ?'" do
      @rule.parse(@content).should == 'I ? and ?'
    end
    
    it ".rule_for_original.parse(@content) should return 'I SEARCH and SEARCH'" do
      @rule.rule_for_original.parse(@content).should == 'I SEARCH and SEARCH'
    end
  end
end
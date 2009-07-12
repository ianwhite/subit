require File.dirname(__FILE__) + '/spec_helper'

describe Subit::Rules do
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
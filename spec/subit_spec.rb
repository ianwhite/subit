require File.dirname(__FILE__) + '/spec_helper'

describe Subit do
  it "should have a version" do
    Subit::Version::String.should =~ /^\d+\.\d+\.\d+/
  end
  
  it ".define should return a Subit::NamedRules object" do
    Subit.define(){}.should be_instance_of(Subit::NamedRules)
  end
  
  describe "(errors)" do
    before { @old = Subit.raise_parse_errors? }

    after { Subit.raise_parse_errors = @old }
    
    it "should default to not be raise parse errors" do
      Subit.should_not be_raise_parse_errors
    end
    
    it "should allow setting of raise parse errors" do
      Subit.raise_parse_errors = true
      Subit.should be_raise_parse_errors
    end
  end
  
  describe ".rule_classes" do
    before do
      Subit.stub(:rule_classes).and_return({})
    end
    
    it ".register_rule(klass) should result in {'klass' => klass}" do
      Subit.register_rule(Integer)
      Subit.rule_classes.should == {'integer' => Integer}
    end
    
    it ".register_rule(klass, name) should result in {'name' => klass}" do
      Subit.register_rule(Integer, 'foo')
      Subit.rule_classes.should == {'foo' => Integer}
    end
    
    describe ".regsiter_rule(Subit::Foo)" do
      before do
        module Subit; class Foo; end; end
        Subit.register_rule(Subit::Foo)
      end
      
      it "should result in {'foo' => Subit::Foo}" do
        Subit.rule_classes.should == {'foo' => Subit::Foo}
      end
      
      it ".rule_class(:foo) should return Subit::Foo" do
        Subit.rule_class(:foo).should == Subit::Foo
      end
      
      it ".rule_class('foo') should return Subit::Foo" do
        Subit.rule_class('foo').should == Subit::Foo
      end
      
      it ".rule_class(:bar) should be non true" do
        (Subit.rule_class(:bar) ? true : false).should == false
      end
      
      it ".rule?(Subit::Foo.new) should be true" do
        Subit.should be_rule(Subit::Foo.new)
      end
      
      it ".rule?('hello') should be false" do
        Subit.should_not be_rule('hello')
      end
    end
  end
  
  describe ".logger" do
    before do
      Rails = mock("Rails") unless defined?(Rails)
    end
    
    after do
      Subit.logger = nil
      Object.instance_eval { remove_const :Rails } if Rails.is_a?(mock.class)
    end
    
    it "should use Rails.logger if available" do
      Rails.stub(:logger).and_return(rails_logger = mock)
      Subit.logger.should == rails_logger
    end

    it "should create new Logger on STDERR if Rails.logger not available" do
      Rails.stub(:logger).and_raise(NoMethodError)
      Logger.should_receive(:new).with(STDERR).and_return(new_logger = mock)
      Subit.logger.should == new_logger
    end
    
    it "should allow setting logger" do
      Subit.logger = :foo
      Subit.logger.should == :foo
    end
    
    it "should cache logger" do
      Subit.logger = Object.new
      Subit.logger.object_id.should == Subit.logger.object_id
    end
  end
end
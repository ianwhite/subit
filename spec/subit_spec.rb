require File.dirname(__FILE__) + '/spec_helper'

describe Subit do
  it "should have a version" do
    Subit::Version::String.should =~ /^\d+\.\d+\.\d+/
  end
  
  it ".rules should return a Subit::Rules object" do
    Subit.rules.should be_instance_of(Subit::Rules)
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
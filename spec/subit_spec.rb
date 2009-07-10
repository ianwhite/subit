require File.dirname(__FILE__) + '/spec_helper'

describe Subit do
  it "should have a version" do
    Subit::Version::String.should =~ /^\d+\.\d+\.\d+/
  end
  
  it ".rules should return a Subit::Rules object" do
    Subit.rules.should be_instance_of(Subit::Rules)
  end
end
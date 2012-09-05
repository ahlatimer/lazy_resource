require 'spec_helper'

describe LazyResource::ConfigurationDelegate do
  subject { LazyResource::ConfigurationDelegate.new }
  it 'forwards the method invocation to Resource if the method is defined there' do
    subject.site.should == 'http://example.com'
  end

  it 'forwards the invocation to LazyResource if the method is defined there' do
    subject.debug.should == false
  end

  it 'raises an error if the method is not defined on one of the delegated classes' do
    lambda { subject.foo }.should raise_error(NoMethodError)
  end
end

require 'spec_helper'

include LazyResource::Types

# This is super hacky. 1.9.3 and Rspec don't seem to set the
# scope correctly, so we have to use fully-qualified named to
# make sure parse is defined on the various types. Oddly enough,
# this isn't required outside the scope of Rspec.
describe LazyResource::Types do
  [LazyResource::Types::Array, LazyResource::Types::String, LazyResource::Types::Boolean, LazyResource::Types::Hash,
   LazyResource::Types::Float, LazyResource::Types::Fixnum].each do |klass|
    describe klass do
      subject { klass }
      it 'adds a parse method' do
        subject.should respond_to(:parse)
      end
    end
  end
end

require 'spec_helper'

include LazyResource::Types

describe LazyResource::Types do
  describe LazyResource::Types::Array do
    it 'adds a parse method' do
      LazyResource::Types::Array.should respond_to(:parse)
    end

    describe '.parse' do
      it 'calls to_a on the passed object' do
        array = []
        array.should_receive(:to_a)
        LazyResource::Types::Array.parse(array)
      end
    end
  end

  describe LazyResource::Types::String do
    it 'adds a parse method' do
      LazyResource::Types::String.should respond_to(:parse)
    end

    describe '.parse' do
      it 'calls to_s on the passed object' do
        string = ''
        string.should_receive(:to_s)
        LazyResource::Types::String.parse(string)
      end
    end
  end

  describe LazyResource::Types::Hash do
    it 'adds a parse method' do
      LazyResource::Types::Hash.should respond_to(:parse)
    end

    it 'returns the passed object' do
      hash = {}
      LazyResource::Types::Hash.parse(hash).should == hash
    end
  end

  describe LazyResource::Types::Boolean do
    it 'adds a parse method' do
      LazyResource::Types::Boolean.should respond_to(:parse)
    end

    describe '.parse' do
      it 'returns true if passed 1, true, \'true\'' do
        ['1', true, 'true'].each do |v|
          LazyResource::Types::Boolean.parse(v).should == true
        end
      end

      it 'returns false otherwise' do
        LazyResource::Types::Boolean.parse('false').should == false
      end
    end
  end

  describe LazyResource::Types::Float do
    it 'adds a parse method' do
      LazyResource::Types::Float.should respond_to(:parse)
    end

    describe '.parse' do
      it 'calls to_f on the passed object' do
        float = '1.0'
        float.should_receive(:to_f)
        LazyResource::Types::Float.parse(float)
      end
    end
  end

  describe LazyResource::Types::Fixnum do
    it 'adds a parse method' do
      LazyResource::Types::Fixnum.should respond_to(:parse)
    end

    describe '.parse' do
      it 'calls to_i on the passed object' do
        int = '1'
        int.should_receive(:to_i)
        LazyResource::Types::Fixnum.parse(int)
      end
    end
  end

  describe LazyResource::Types::DateTime do
    it 'adds a parse method' do
      LazyResource::Types::DateTime.should respond_to(:parse)
    end

    describe '.parse' do
      it 'returns the passed object if it is already a DateTime' do
        date = DateTime.parse('01-01-2012 00:00:00 -0500')
        LazyResource::Types::DateTime.parse(date).should == date
      end

      it 'calls DateTime.parse otherwise' do
        date_string = '01-01-2012 00:00:00 -0500'
        ::DateTime.should_receive(:parse).with(date_string)
        LazyResource::Types::DateTime.parse(date_string)
      end
    end
  end
end

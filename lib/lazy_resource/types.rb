module LazyResource
  module Types
    class Array < ::Array
      def self.parse(o)
        o.to_a
      end
    end

    class String < ::String
      def self.parse(o)
        o.to_s
      end
    end

    class Fixnum < ::Fixnum
      def self.parse(o)
        o.to_i
      end
    end

    class Boolean
      def self.parse(o)
        if [true, '1', 'true'].include? o
          true
        else
          false
        end
      end
    end

    class Float < ::Float
      def self.parse(o)
        o.to_f
      end
    end

    class Hash < ::Hash
      def self.parse(o)
        o
      end
    end

    class DateTime < ::DateTime
      def self.parse(o)
        if o.is_a?(::DateTime)
          o
        else
          super(o)
        end
      end
    end
  end
end

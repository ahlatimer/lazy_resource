module LazyResource
  module RequestDSL
    extend ActiveSupport::Concern

    module ClassMethods
      def params(params={});   Request.new(self).params(params); end
      def route(*args);        Request.new(self).route(*args); end
      def headers(headers={}); Request.new(self).headers(headers); end
      def body(body);          Request.new(self).body(body); end
      def method(method);      Request.new(self).method(method); end
    end
  end
end

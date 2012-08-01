module LazyResource
  class HttpMock
    class Responder
      [:post, :put, :get, :delete].each do |method|
        module_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{method}(path, body='', status=200, response_headers={})
            request_queue.stub(:#{method}, path).and_return(Typhoeus::Response.new(:code => status, :headers => response_headers, :body => body, :time => 0.3))
          end
        RUBY
      end

      def request_queue
        Thread.current[:request_queue] ||= Typhoeus::Hydra.new
      end
    end

    class << self
      def respond_to(*args)
        yield Responder.new
      end
    end
  end
end

# frozen_string_literal: true

module HttpClient
  extend ActiveSupport::Concern

  private

    def ping(host, timeout: 0.2)
      host ||= ""
      uri = URI.parse(host)

      Timeout.timeout(timeout) do
        s = TCPSocket.new(uri.host, uri.port)
        s.close
      rescue SocketError => e
        raise Exception.new("#{host} service not exist: #{e.message}")
      end
    end

    def http
      @http ||= Faraday::Connection.new(nil, parallel_manager: Typhoeus::Hydra.new(max_concurrency: 20)) do |b|
        b.options[:open_timeout] = 2
        b.options[:timeout] = 5
        b.request :retry,
          exceptions: [Faraday::Error::TimeoutError, Faraday::Error::ConnectionFailed, Faraday::Error::ClientError],
          retry_if: ->(env, _exception) { !(400..499).include?(env.status) }
        b.response :raise_error
        b.adapter :typhoeus
      end
    end
end
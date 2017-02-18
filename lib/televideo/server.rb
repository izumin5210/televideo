require 'vcr'

module Televideo
  class Server
    HEADER_PREFIX = 'HTTP_X_TELEVIDEO'
    HEADER_CASSETTE_NAME = "#{HEADER_PREFIX}_CASSETTE_NAME"
    CUSTOM_HEADERS = [
      HEADER_CASSETTE_NAME,
    ]

    def initialize(cassette:, uri:, https: false, vcr_options: {})
      @cassette = cassette
      @uri = @uri.is_a?(URI) ? uri : URI(uri)
      @vcr_options = vcr_options
      @https = https
    end

    def call(env)
      name = cassette_name_from_env(env)
      res = VCR::use_cassette(name, @vcr_options) { run_request(env) }
      [
        res.code,
        headers_from_response(res),
        [res.body]
      ]
    end

    private

    def run_request(env)
      orig_req = Rack::Request.new(env)
      headers = headers_hash_from_env(env)

      http = Net::HTTP.new(@uri.host, @uri.port)

      if @https
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      http.start do
        m = orig_req.request_method

        req = Net::HTTP.const_get(m.capitalize).new(orig_req.fullpath, headers)

        if orig_req.body
          req.body_stream = orig_req.body
          req.content_length = orig_req.content_length.to_i
          req.content_type = orig_req.content_type if orig_req.content_type
          req.body_stream.rewind
        end

        http.request(req)
      end
    end

    def cassette_name_from_env(env)
      "#{@cassette}/#{env[HEADER_CASSETTE_NAME] || default_cassette_name_from_env(env)}"
    end

    def default_cassette_name_from_env(env)
      "#{env['REQUEST_METHOD']}_#{env['REQUEST_PATH'][1..-1].gsub('/', '-')}"
    end

    def headers_hash_from_env(env)
      env.select { |k, _| k.start_with?('HTTP_') }
        .map { |k, v| [normalize_header_field(k), v] }
        .reject { |(k, _)| CUSTOM_HEADERS.include?(k) }
        .to_h
    end

    def normalize_header_field(k)
      k.gsub(/^HTTP_/, '').split('_').map(&:capitalize).join('-')
    end

    def headers_from_response(res)
      Rack::Utils::HeaderHash.new(reject_header_fields(res.to_hash))
    end

    def reject_header_fields(headers)
      headers.reject do |k|
        [
          'connection',
          'keep-alive',
          'proxy-authenticate',
          'proxy-authorization',
          'te',
          'trailer',
          'transfer-encoding',
          'upgrade',
        ].include?(k.downcase)
      end
    end
  end
end

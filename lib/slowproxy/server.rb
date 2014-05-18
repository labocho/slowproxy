require 'webrick/httpproxy'

module Slowproxy
  class Server < WEBrick::HTTPProxyServer
    def initialize(config, default = WEBrick::Config::HTTP)
      @bps = config.delete(:BPS)
      SlowBufferedIO.bps = @bps if @bps
      super
      logger.info "#{number_to_human_size(@bps)}bps"
      SlowBufferedIO.logger = logger
    end

    def number_to_human_size(n)
      suffixes = ["", "K", "M", "G"]
      suffixes.each_with_index.to_a.reverse.each do |suffix, index|
        one = 1024 ** index
        return "#{n / one} #{suffix}" if n >= one
      end
    end

    def perform_proxy_request(req, res)
      uri = req.request_uri
      path = uri.path.dup
      path << "?" << uri.query if uri.query
      header = setup_proxy_header(req, res)
      upstream = setup_upstream_proxy_authentication(req, res, header)
      response = nil

      http = Net::HTTP.new(uri.host, uri.port, upstream.host, upstream.port)
      http.start do
        ########## prepend Net::SlowBufferedIO
        http.instance_eval do
          class << @socket
            prepend Slowproxy::SlowBufferedIO
          end
        end
        ########## /prepend Net::SlowBufferedIO
        if @config[:ProxyTimeout]
          ##################################   these issues are
          http.open_timeout = 30   # secs  #   necessary (maybe because
          http.read_timeout = 60   # secs  #   Ruby's bug, but why?)
          ##################################
        end
        response = yield(http, path, header)
      end

      # Persistent connection requirements are mysterious for me.
      # So I will close the connection in every response.
      res['proxy-connection'] = "close"
      res['connection'] = "close"

      # Convert Net::HTTP::HTTPResponse to WEBrick::HTTPResponse
      res.status = response.code.to_i
      choose_header(response, res)
      set_cookie(response, res)
      set_via(res)
      res.body = response.body
    end
  end
end

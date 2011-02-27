require 'uri'
require 'faraday'
require 'rack'
require 'webrick'
require 'socket'

Thread.abort_on_exception = true

module SpecHelpers
  RACK_ENV_KEYS = [ 'PATH_INFO', 'REQUEST_METHOD', 'QUERY_STRING', 'rack.input',
                    'HTTP_X_ZOMG' ]

  def self.launch_test_server
    @test_server ||= begin
      app = lambda do |env|
        ret = env.slice(*RACK_ENV_KEYS)
        ret['rack.input'] = ret['rack.input'].read if ret['rack.input']
        [ 200, { 'Content-Type' => 'text/plain' }, ret.inspect ]
      end

      t = Thread.new do
        logger = WEBrick::Log.new(nil, WEBrick::BasicLog::WARN)
        Rack::Handler::WEBrick.run(app, :Host   => '0.0.0.0', :Port => 9293,
                                        :Logger => logger, :AccessLog => [])
      end

      begin
        s = TCPSocket.new('0.0.0.0', 9293)
      rescue Errno::ECONNREFUSED
        sleep 0.2
        retry
      end

      s.close
      t
    end
  end

  def launch_test_server
    SpecHelpers.launch_test_server
  end

  %w( get post put delete head ).each do |method|
    class_eval <<-RUBY
      def #{method}(uri, *args)
        request(:#{method}, uri, *args)
      end
    RUBY
  end

  attr_reader :response
  attr_reader :host

  def host!(host)
    @host = host
  end

  def request(method, uri, *args)
    uri     = URI(uri)
    host    = uri.host   || @host
    scheme  = uri.scheme || 'http'
    headers = Hash === args.last ? args.pop : {}

    if host == :preview
      ip = host = 'http://localhost:9292'
    else
      ip = ENV['GUIDES_URL']
    end

    headers['Host'] = host
    headers['Authorization'] = 'basic x:x' # hac to bypass varnish

    conn = Faraday::Connection.new(:url => ip) do |c|
      c.use Faraday::Adapter::NetHttp
      c.headers.merge! headers
    end

    path = uri.path
    path = "#{path}?#{uri.query}" if uri.query

    begin
      @response = conn.run_request(method, path, args.first, {})
    rescue StandardError
      sleep 0.5
      retry
    end
  end

  def should_respond_with(status, body = nil, hdrs = {})
    @response.status.should == status

    if body.is_a?(Regexp)
      @response.body.should =~ body
    elsif body
      @response.body.should == body
    end

    hdrs.each do |hdr, val|
      @response.headers[hdr].should == val
    end
  end

  def should_have_env(env)
    @response.status.should == 200
    empty  = RACK_ENV_KEYS - env.keys
    actual = eval(@response.body)

    env.each do |key, val|
      actual[key].should == val
    end

    empty.each do |key|
      actual[key].should be_blank
    end
  end
end


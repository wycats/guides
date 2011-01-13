require "rack"

module Guides
  class App
    LOCAL_ASSETS     = File.expand_path("../templates/assets", __FILE__)
    SOURCE_ASSETS    = File.join(Guides.root, "assets")
    SOURCE_TEMPLATES = File.join(Guides.root, "source")

    def initialize
      @local  = Rack::File.new(LOCAL_ASSETS)
      @source = Rack::File.new(SOURCE_ASSETS)
      @output = Rack::File.new(File.join(Guides.root, "output"))
    end

    def call(env)
      path = env["PATH_INFO"]

      case path
      when "/"
        env["PATH_INFO"] = "/index.html"
        return call(env)
      when /(.*).html/
        name = $1
        generator = Guides::Generator.new({})
        source_file = Dir["#{SOURCE_TEMPLATES}/#{name}.{html.erb,textile}"].first

        unless source_file
          return [404, {"Content-Type" => "text/html"}, ["#{name} not found"]]
        end

        generator.send(:generate_guide, File.basename(source_file), "#{name}.html")
        return @output.call(env)
      else
        source = @source.call(env)
        return source if source.first == 200
        return @local.call(env)
      end
    end
  end

  class Preview < Rack::Server
    def self.start(*)
      super :host => '0.0.0.0', :Port => 9292, :server => "thin"
    end

    def app
      @app ||= App.new
    end
  end
end

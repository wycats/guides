require "rack"

module Guides
  class App
    def initialize(options = {})
      @local  = Rack::File.new(local_assets)
      @source = Rack::File.new(source_assets)
      @output = Rack::File.new(File.join(Guides.root, "output"))
      @production = !!options[:production]
    end

    def local_assets
      File.expand_path("../templates/assets", __FILE__)
    end

    def source_assets
      File.join(Guides.root, "assets")
    end

    def source_templates
      File.join(Guides.root, "source")
    end

    def call(env)
      path = env["PATH_INFO"]

      case path
      when "/"
        env["PATH_INFO"] = "/index.html"
        return call(env)
      when /\/(.*)\.html$/
        name = $1
        generator = Guides::Generator.new({ :production => @production })

        source_file = Dir["#{source_templates}/#{name}.{#{Guides::Generator::EXTENSIONS.join(",")}}"].first

        unless source_file
          return [404, {"Content-Type" => "text/html"}, ["#{name} not found in #{source_templates}: #{Guides.root}"]]
        end

        source_base = File.basename(source_file)

        if generator.construction?(source_base) && @production
          return [404, {"Content-Type" => "text/html"}, ["#{name} is under construction and not available in production"]]
        end

        generator.send(:generate_guide, source_base, "#{name}.html")
        return @output.call(env)
      else
        source = @source.call(env)
        return source if source.first == 200
        return @local.call(env)
      end
    end
  end

  class Preview < Rack::Server
    def self.start(options = {})
      super options.merge(:host => '0.0.0.0', :Port => 9292, :server => "thin")
    end

    def initialize(options = {})
      @production = !!options[:production]
      super(options)
    end

    def app
      @app ||= App.new(:production => @production)
    end
  end
end

require "thor"
require "guides/new"
require "guides/preview"
require "guides/version"

module Guides
  class CLI < Thor
    ASSETS_ROOT = File.expand_path("../assets", __FILE__)
    SOURCE_ROOT = File.expand_path("../source", __FILE__)

    def self.basename
      "guides"
    end

    desc "new NAME", "create a new directory of guides"
    method_option "name", :type => :string
    def new(name)
      invoke "guides:new:copy", [name, options[:name] || name]
    end

    desc "build", "build the guides output"
    method_option "only", :type => :array
    method_option "clean", :type => :boolean
    method_option "edge", :type => :boolean, :default => false
    method_option "production", :type => :boolean, :default => true, :banner => "use production mode", :aliases => "-p"
    def build
      if options[:clean]
        FileUtils.rm_rf(File.join(Guides.root, options[:production] ? 'output' : 'staging'))
      end

      require "guides/generator"

      opts = options.dup

      opts[:only] ||= []

      generator = Guides::Generator.new(opts)
      generator.generate
    end

    map "-v"        => "version"
    map "--version" => "version"

    desc "version", "print the current version"
    def version
      shell.say "Guides #{Guides::VERSION}", :green
    end

    desc "preview", "preview the guides as you work"
    method_option "production", :type => :boolean, :banner => "use production mode", :aliases => "-p"
    method_option "port",       :type => :string,  :default => "9292"
    def preview
      Preview.start(options)
    end

    #desc "update", "when running from the pkg, updates the gem"
    #def update
      #Update.start
    #end

    no_tasks do
      def invoke_task(*)
        super
      rescue Guides::Error => e
        shell.say e.message, :red
        exit e.status_code
      end
    end
  end
end

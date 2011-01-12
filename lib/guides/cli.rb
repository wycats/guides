require "thor"
require "guides/new"

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

    desc "generate", "generate the guides output"
    method_option "only", :type => :array
    method_option "clean", :type => :boolean
    def generate
      FileUtils.rm_rf("#{Guides.root}/output") if options[:clean]
      require "guides/generator"

      opts = options.dup

      opts[:only] ||= []

      generator = Guides::Generator.new(opts)
      generator.generate
    end

    desc "preview", "preview the guides as you work"
    def preview

    end

    desc "update", "when running from the pkg, updates the gem"
    def update

    end

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

require "thor"

module Guides
  class CLI < Thor
    ASSETS_ROOT = File.expand_path("../assets", __FILE__)
    SOURCE_ROOT = File.expand_path("../source", __FILE__)

    desc "new NAME", "create a new directory of guides"
    def new(name)
      FileUtils.mkdir_p(name)

      Dir.chdir(name) do
        FileUtils.mkdir_p("source")
        FileUtils.cp_r Dir["#{SOURCE_ROOT}/**/*"], "source"

        File.open("guides.yml", "w") do |file|
          file.puts "title: #{name}"
        end

        FileUtils.mkdir_p("assets")
        FileUtils.cp_r Dir["#{ASSETS_ROOT}/*"], "assets"
      end
    end

    desc "generate", "generate the guides output"
    method_option "only", :type => :array
    def generate
      FileUtils.mkdir_p("#{Guides.root}/output")
      require "guides/generator"

      opts = options.dup

      opts[:only] ||= []

      generator = Guides::Generator.new(opts)
      generator.generate
    end

    desc "preview", "preview the guides as you work"
    def preview

    end
  end
end

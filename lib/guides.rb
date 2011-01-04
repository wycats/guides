require "action_pack"
require "redcloth"

require "guides/textile_extensions"
require "guides/generators"

module Guides
  class << self
    def root
      # TODO: Search for guides.yml
      File.expand_path(Dir.pwd)
    end

    def meta
      @meta ||= begin
        if File.exist?("#{root}/guides.yml")
          YAML.load_file("#{root}/guides.yml")
          # TODO: Sanity check the output
        else
          raise "#{root}/guides.yml was not found"
        end
      end
    end
  end
end

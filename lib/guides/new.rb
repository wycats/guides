module Guides
  class New < Thor
    include Thor::Actions

    source_root File.expand_path("../templates", __FILE__)

    desc "copy DEST NAME", "copy stuff"
    def copy(destination, name)
      self.destination_root = File.expand_path(destination)
      self.title = name

      directory "source"
      empty_directory "assets/stylesheets"
      empty_directory "assets/images"
      empty_directory "assets/javascripts"

      template "guides.yml.tt", "guides.yml"
      create_file "assets/stylesheets/overrides.style.css"
      create_file "assets/stylesheets/overrides.print.css"
    end

    no_tasks do
      attr_accessor :title
    end
  end
end

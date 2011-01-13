desc "Prep the release for PackageMaker"
task :pkg do
  system "rm -rf Guides"
  system "mkdir -p Guides/local/guides/lib"

  `git ls-files -- lib`.split("\n").each do |file|
    system "mkdir -p #{File.dirname("Guides/local/guides/#{file}")}"
    system "cp #{file} Guides/local/guides/#{file}"
  end

  require "rbconfig"

  unless Config::CONFIG["target_cpu"] == "universal"
    puts "Please use a universal binary copy of ruby"
    exit 1
  end

  unless RUBY_VERSION == "1.9.2"
    puts "Please use Ruby 1.9.2"
    exit 1
  end

  puts "Regenerating the bundle."

  system "rm -rf bundle"
  system "bundle --standalone"
  system "cp -R bundle Guides/local/guides/bundle"

  guides = File.read("bin/guides").sub(/\A#.*/, "#!/usr/local/ruby1.9test/bin/ruby -I /usr/local/guides/bundle -r bundler/setup")

  system "mkdir -p Guides/bin"
  File.open("Guides/bin/guides", "w") { |file| file.puts guides }
end

file "Guides/local/guides/bundle" => "Gemfile" do
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

  sh "rm -rf bundle"
  sh "bundle --standalone --local --without development"
  sh "mkdir -p Guides/local/guides"
  sh "cp -R bundle Guides/local/guides/"

  verbose(false) do
    Dir.chdir("Guides/local/guides/bundle/ruby/1.9.1") do
      Dir["{bin,cache,doc,specifications}"].each { |f| rm_rf f }
      Dir["**/{ext,docs,test,spec}"].each { |f| rm_rf(f) if File.directory?(f) }
      Dir["**/erubis-*/doc-api"].each {|f| rm_rf(f) }
    end
  end
end

file "Guides/local/guides/lib"

`git ls-files -- lib`.split("\n").each do |file|
  dest = "Guides/local/guides/#{file}"
  file dest => file do
    verbose(false) { mkdir_p File.dirname(dest) }
    cp_r file, dest
  end
  task "Guides/local/guides/lib" => dest
end

file "Guides/bin/guides" => "bin/guides" do
  guides = File.read("bin/guides").sub(/\A#.*/, "#!/usr/local/ruby1.9test/bin/ruby -I /usr/local/guides/bundle -r bundler/setup")

  sh "mkdir -p Guides/bin"
  File.open("Guides/bin/guides", "w") { |file| file.puts guides }
end

desc "Prep the release for PackageMaker"
task :pkg => ["Guides/local/guides/bundle", "Guides/local/guides/lib", "Guides/bin/guides"]

task :rm do
  rm_rf "Guides"
end

task :clean => [:rm, :pkg]

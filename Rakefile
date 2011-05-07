require "bundler/setup"
require "guides/version"
require "erb"

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
  sh "rm -rf .bundle"
  sh "rm -rf guides-pkg"
  sh "rm Guides.pkg"
  Bundler.with_clean_env do
    sh "bundle --standalone --without development"
  end
  sh "mkdir -p Guides/local/guides"
  sh "cp -R bundle Guides/local/guides/"

  verbose(false) do
    Dir.chdir("Guides/local/guides/bundle/ruby/1.9.1") do
      Dir["{bin,cache,doc,specifications}"].each { |f| rm_rf f }
      Dir["**/{ext,docs,test,spec}"].each { |f| rm_rf(f) if File.directory?(f) && f !~ /maruku/i }
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
  guides = File.read("bin/guides").sub(/\A#.*/, "#!/usr/local/ruby1.9/bin/ruby -I /usr/local/guides/bundle -r bundler/setup")

  sh "mkdir -p Guides/bin"
  File.open("Guides/bin/guides", "w") { |file| file.puts guides }
  File.chmod 0755, "Guides/bin/guides"
end

desc "Prep the release for PackageMaker"
task :make_pkg => ["Guides/local/guides/bundle", "Guides/local/guides/lib", "Guides/bin/guides"]

task :rm do
  rm_rf "Guides"
end

directory "guides-pkg/Resources"
directory "guides-pkg/guides.pkg"

pkg_dependencies = [:make_pkg, "guides-pkg/Resources", "guides-pkg/guides.pkg",
  "guides-pkg/Distribution", "guides-pkg/guides.pkg/Bom",
  "guides-pkg/guides.pkg/PackageInfo", "guides-pkg/guides.pkg/Payload"]

def details
  @details ||= begin
    total_size, files = 0, 0

    Dir["Guides/**/*"].each do |file|
      files += 1

      next if File.directory?(file)

      total_size += File.size(file)
    end

    [total_size, files]
  end
end

file "guides-pkg/Distribution" do
  src = File.read File.expand_path("../build/Distribution.erb", __FILE__)
  erb = ERB.new(src)

  total_size, files = details

  kbytes = total_size / 1024
  version = Guides::VERSION

  File.open("guides-pkg/Distribution", "w") do |file|
    file.puts erb.result(binding)
  end
end

file "guides-pkg/guides.pkg/PackageInfo" do
  src = File.read File.expand_path("../build/PackageInfo.erb", __FILE__)
  erb = ERB.new(src)

  total_size, num_files = details

  kbytes = total_size / 1024
  version = Guides::VERSION

  File.open("guides-pkg/guides.pkg/PackageInfo", "w") do |file|
    file.puts erb.result(binding)
  end
end

file "guides-pkg/guides.pkg/Bom" do
  sh "mkbom -s Guides guides-pkg/guides.pkg/Bom"
end

file "guides-pkg/guides.pkg/Payload" do
  sh "cd Guides && pax -wz -x cpio . > ../guides-pkg/guides.pkg/Payload"
end

file "Guides.pkg" => pkg_dependencies do
  sh "pkgutil --flatten guides-pkg Guides.pkg"
end

task :pkg => "Guides.pkg"

task :clean => [:rm, :pkg]

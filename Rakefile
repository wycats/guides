require File.expand_path('../lib/guides/version', __FILE__)

begin
  require 'packager/rake_task'

  Packager::RakeTask.new(:pkg) do |t|
    t.version = Guides::VERSION
    t.domain = "strobecorp.com"
    t.package_name = "Guides"
    t.bin_files = ['guides']
  end
rescue LoadError
  puts "`gem install packager` for packaging tasks"
end

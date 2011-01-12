require "fileutils"
require "pathname"
require "support/cli"

RSpec.configure do |config|
  include SpecHelpers

  def tmp
    @tmp ||= Pathname.new(File.expand_path("../../tmp", __FILE__))
  end

  config.before(:suite) do
    FileUtils.rm_rf(tmp)
    FileUtils.mkdir_p(tmp)
    Dir.chdir(tmp)
  end
end

require "fileutils"
require "pathname"
require "support/cli"
require "support/rack"

RSpec.configure do |config|
  include SpecHelpers

  def tmp
    @tmp ||= Pathname.new(File.expand_path("../../tmp", __FILE__))
  end

  def reset_tmp
    FileUtils.rm_rf(tmp)
    FileUtils.mkdir_p(tmp)
    Dir.chdir(tmp)
  end

  def fixtures
    @fixtures ||= Pathname.new(File.expand_path("../fixtures", __FILE__))
  end

  config.before(:suite) do
    reset_tmp
  end
end

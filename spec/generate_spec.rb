require "spec_helper"

describe "guides generate" do
  before(:all) do
    FileUtils.rm_rf(tmp.join("sample"))
    guides "new", "sample"
    wait
    Dir.chdir(tmp.join("sample"))
    guides "generate"
  end

  after(:all) do
    Dir.chdir(tmp)
  end

  it "generates the app" do
    out.should =~ /Generating contribute.html.*Generating credits.html.*Generating index.html/m
  end

  it "creates index.html" do
    File.read("output/index.html").should =~ /<a href="contribute.html">/
  end

  it "creates contribute.html" do
    contribute = File.read("output/contribute.html")
    contribute.should =~ /<h2>Contribute<\/h2>/
  end
end


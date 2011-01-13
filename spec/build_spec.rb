require "spec_helper"

describe "guides build" do
  before(:all) do
    reset_tmp
    guides "new", "sample" and wait
    Dir.chdir tmp.join("sample")
    guides "build" and wait
  end

  it "generates the app" do
    out.should =~ /Generating contribute.html.*Generating credits.html.*Generating index.html/m
  end

  it "generates assets" do
    files = Dir["output/*"]

    File.directory?("output/images").should be_true
    File.directory?("output/javascripts").should be_true
    File.directory?("output/stylesheets").should be_true
    File.file?("output/javascripts/guides.js").should be_true
    File.file?("output/stylesheets/main.css").should be_true
    File.file?("output/stylesheets/overrides.style.css").should be_true
  end

  it "does nothing if run twice in a row" do
    guides "build"
    out.should be_blank
  end

  it "re-runs if run with --clean" do
    guides "build", "--clean"
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


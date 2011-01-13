require "spec_helper"

describe "guides generate" do
  before(:all) do
    reset_tmp
    guides "new", "sample" and wait
    Dir.chdir tmp.join("sample")
    guides "build" and wait
  end

  after(:all) do
    Dir.chdir(tmp)
  end

  before(:each) do
    host! :preview
    launch_test_server
    guides "preview"
  end

  it "downloads the index at /" do
    get "/"
    should_respond_with 200, /<!DOCTYPE html PUBLIC.*>.*<h3>Start Here<\/h3>/m
  end

  it "downloads the index at /index.html" do
    get "/"
    should_respond_with 200, /<!DOCTYPE html PUBLIC.*>.*<h3>Start Here<\/h3>/m
  end

  it "downloads contribute at /contribute.html" do
    get "/contribute.html"
    should_respond_with 200, /<!DOCTYPE html PUBLIC.*>.*<h2>Contribute<\/h2>/m
  end
end

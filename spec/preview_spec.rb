require "spec_helper"

describe "guides preview" do
  before(:all) do
    reset_tmp
    guides "new", "sample" and wait
    copy_fixtures
    Dir.chdir tmp.join("sample")
  end

  after(:all) do
    Dir.chdir(tmp)
  end

  describe "without arguments" do

    before(:each) do
      host! :preview
      guides "preview"
    end

    after(:each) do
      kill!
    end

    it "downloads the index at /" do
      get "/"
      should_respond_with 200, /<!DOCTYPE html PUBLIC.*>.*<h3>Section One<\/h3>/m
    end

    it "downloads the index at /index.html" do
      get "/"
      should_respond_with 200, /<!DOCTYPE html PUBLIC.*>.*<h3>Section One<\/h3>/m
    end

    it "downloads contribute at /contribute.html" do
      get "/contribute.html"
      should_respond_with 200, /<!DOCTYPE html PUBLIC.*>.*<h2>Contribute<\/h2>/m
    end

    it "downloads a normal page" do
      get "/article_one.html"
      should_respond_with 200, /<!DOCTYPE html PUBLIC.*>.*<h2>Article One<\/h2>/m
    end

    it "downloads an under-construction page" do
      get "/article_four.html"
      should_respond_with 200, /<!DOCTYPE html PUBLIC.*>.*<h2>Article Four<\/h2>/m
    end

  end

  describe "production" do

    before(:each) do
      host! :preview
      guides "preview", "--production"
    end

    after(:each) do
      kill!
    end

    it "downloads a normal page" do
      get "/article_one.html"
      should_respond_with 200, /<!DOCTYPE html PUBLIC.*>.*<h2>Article One<\/h2>/m
    end

    it "does not download an under-construction page" do
      get "/article_four.html"
      should_respond_with 404, "article_four is under construction and not available in production"
    end

  end

end

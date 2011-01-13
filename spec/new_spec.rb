require "spec_helper"

describe "guides new" do
  before(:each) do
    reset_tmp
  end

  it "prints an error if new is called with no name" do
    guides "new", :track_stderr => true
    err.should =~ /"new" was called incorrectly/
  end

  it "generates an app if a name is given" do
    guides "new", "sample"
    out.should =~ /create.*guides\.yml/
    tmp.join("sample", "guides.yml").read.should =~ /\Atitle: sample/
  end
end

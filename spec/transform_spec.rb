require "spec_helper"

describe "Transformer" do
  before do
    @transformer = Guides::TextileTransformer.new
  end

  it "handles regular textile" do
    @transformer.transform("h1. foo\n\nbar").should == "<h1>foo</h1>\n<p>bar</p>\n"
  end

  it "handles <code>" do
    result = @transformer.transform("h1. foo\n\n+foo*bar*baz is <bat>+")
    result.should == "<h1>foo</h1>\n<tt>foo*bar*baz is &lt;bat&gt;</tt>\n"
  end

  it "handles <javascript>" do
    result = @transformer.transform("h1. foo\n\nHi there.\n\n<javascript>SC.Object.extend({\n  foo: function() {\n    return foo < bar && baz\n  }\n})</javascript>")
    result.should == %{<h1>foo</h1>\n<p>Hi there.</p>\n<div class="code_container">\n<pre class="brush: javascript; gutter: false; toolbar: false">\n} +
                     %{SC.Object.extend({\n  foo: function() {\n    return foo &lt; bar &amp;&amp; baz\n  }\n})</pre></div>\n}
  end

  it "handles <ruby>" do
    result = @transformer.transform("h1. foo\n\nHi there.\n\n<ruby>class Foo < Bar\n  def foo\n    bar && baz\n  end\nend</ruby>")
    result.should == %{<h1>foo</h1>\n<p>Hi there.</p>\n<div class="code_container">\n<pre class="brush: ruby; gutter: false; toolbar: false">\n} +
      %{class Foo &lt; Bar\n  def foo\n    bar &amp;&amp; baz\n  end\nend</pre></div>\n}
  end

  it "handles <erb>" do
    result = @transformer.transform("h1. foo\n\nHi there.\n\n<erb><div><%= ohai %></div></erb>")
    result.should == %{<h1>foo</h1>\n<p>Hi there.</p>\n<div class="code_container">\n<pre class="brush: ruby; html-script: true; gutter: false; toolbar: false">\n} +
      %{&lt;div&gt;&lt;%= ohai %&gt;&lt;/div&gt;</pre></div>\n}
  end

  it "handles <shell>" do
    result = @transformer.transform("h1. foo\n\nHi there.\n\n<shell>$ foo && bar</shell>")
    result.should == %{<h1>foo</h1>\n<p>Hi there.</p>\n<div class="code_container">\n<pre class="brush: plain; gutter: false; toolbar: false">\n} +
      %{$ foo &amp;&amp; bar</pre></div>\n}
  end
end

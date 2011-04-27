require "spec_helper"

describe "Transformer" do
  before do
    @transformer = Guides::TextileTransformer.new(true)
    @dev_transformer = Guides::TextileTransformer.new
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

  it "handles <javascript> with a filename" do
    result = @transformer.transform("h1. foo\n\nHi there.\n\n<javascript filename='fake.js'>SC.Object.extend({\n  foo: function() {\n    return foo < bar && baz\n  }\n})</javascript>")
    result.should == %{<h1>foo</h1>\n<p>Hi there.</p>\n<div class="code_container">\n<div class="filename">fake.js</div>\n} +
                     %{<pre class="brush: javascript; gutter: false; toolbar: false">\n} +
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

  it "handles <css>" do
    result = @transformer.transform("h1. foo\n\nHi there.\n\n<css>body { color: red; };\na { color: blue; }</css>")
    result.should == %{<h1>foo</h1>\n<p>Hi there.</p>\n<div class="code_container">\n} +
                      %{<pre class="brush: css; gutter: false; toolbar: false">\n} +
                      %{body { color: red; };\na { color: blue; }</pre></div>\n}
  end

  it "handles NOTE:" do
    result = @transformer.transform("h1. foo\n\nHi there.\n\nNOTE: Some note\nmore of *the same* note\n\nAnother paragraph")
    result.should == %{<h1>foo</h1>\n<p>Hi there.</p>\n<div class="note"><p>Some note more of <strong>the same</strong> note</p></div>\n} +
      %{<p>Another paragraph</p>\n}
  end

  it "does not convert single line breaks to <br>" do
    @transformer.transform("This\nhas\nbreaks.").should == "<p>This has breaks.</p>\n"
    @transformer.transform("This\nhas\nbreaks.\n\nAnd\nparagraphs.").should == "<p>This has breaks.</p>\n<p>And paragraphs.</p>\n"
  end

  it "handles <construction>" do
    str = "Testing this out. <construction>Write more here later.</construction> This is awesome.\n"
    @transformer.transform(str).should == "<p>Testing this out.  This is awesome.</p>\n"
    @dev_transformer.transform(str).should == "<p>Testing this out. Write more here later. This is awesome.</p>\n"

    str = "Before\n\n<construction>Blah</construction>\n\nAfter"
    @transformer.transform(str).should == "<p>Before</p>\n<p>After</p>\n"
    @dev_transformer.transform(str).should == "<p>Before</p>\n<p>Blah</p>\n<p>After</p>\n"

    @dev_transformer.transform("<construction>+Test+</construction>").should == "<tt>Test</tt>\n"
  end

  it "handles +" do
    @transformer.transform("This +is a+ test.").should == "<p>This <tt>is a</tt> test.</p>\n"
    @transformer.transform("This +is+ a +test+.").should == "<p>This <tt>is</tt> a <tt>test</tt>.</p>\n"
    @transformer.transform("This +is a test.").should == "<p>This +is a test.</p>\n"
    @transformer.transform("This + is + a + test.").should == "<p>This + is + a + test.</p>\n"
  end

end

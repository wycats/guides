# Hack for buggy method that thinks NOTE is an email header
class MaRuKu::MDDocument
  def parse_email_headers(s)
    { :data => s}
  end
end


OpenCodeRegexp = /<(yaml|shell|ruby|erb|html|sql|plain|javascript|css)>/
CloseCodeRegexp = lambda{|type| /<\/#{type}>/ }

NoteRegexp = /^(IMPORTANT|CAUTION|WARNING|NOTE|INFO|TIP)[.:](.*)/

Maruku::In::Markdown.register_block_extension(
  :regexp => OpenCodeRegexp,
  :handler => lambda{|doc, src, context|
    # Double check first line to get type
    type = src.shift_line.match(OpenCodeRegexp)[1]

    # Get all intermediate lines
    body = ""
    while src.cur_line && src.cur_line !~ CloseCodeRegexp.call(type)
      body << src.shift_line + "\n"
    end

    # Throw away last line
    src.shift_line


    brush = case type
      when 'ruby', 'sql', 'javascript', 'css', 'plain'
        type
      when 'erb'
        'ruby; html-script: true'
      when 'html'
        'xml' # html is understood, but there are .xml rules in the CSS
      else
        'plain'
    end

    context.push doc.md_html(<<HTML
<div class="code_container">
<pre class="brush: #{brush}; gutter: false; toolbar: false">
#{ERB::Util.h(body.strip)}
</pre>
</div>
HTML
    )
    true
  }
)


Maruku::In::Markdown.register_block_extension(
  :regexp => NoteRegexp,
  :handler => lambda{|doc, src, context|
    # Double check first line to get type and starting text
    type, body = src.shift_line.match(NoteRegexp).captures

    # Get all intermediate lines
    while src.cur_line && src.cur_line.strip.length > 0
      body << " #{src.shift_line}"
    end

    css_class = type.downcase
    css_class = 'warning' if ['caution', 'important'].include?(css_class)
    css_class = 'info' if css_class == 'tip'

    result = "<div class='#{css_class}'><p>"
    result << body.strip
    result << '</p></div>'

    context.push doc.md_html(result)
    true
  }
)


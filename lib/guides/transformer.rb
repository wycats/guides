require "strscan"
require "cgi"

module Guides
  class TextileTransformer
    LANGUAGES = { "ruby" => "ruby", "sql" => "sql", "javascript" => "javascript",
                  "css" => "css", "plain" => "plain", "erb" => "ruby; html-script: true",
                  "html" => "xml", "xml" => "xml", "shell" => "plain", "yaml" => "yaml" }

    def transform(string)
      @string = string.dup

      @output  = ""
      @pending_textile = ""

      until @string.empty?
        match = scan_until /(\+(.*?)\+|<(#{LANGUAGES.keys.join("|")})>|\z)/m

        @pending_textile << match.pre_match

        case match[1]
        when /^[^\+]/
          flush_textile
          generate_brushes match[3], LANGUAGES[match[3]]
        when ""
        else
          @pending_textile << "<notextile><tt>#{CGI.escapeHTML(match[2])}</tt></notextile>" if match[2]
        end
      end

      flush_textile

      @output
    end

    def generate_brushes(tag, replace)
      match = scan_until %r{</#{tag}>}
      @output << %{<div class="code_container">\n<pre class="brush: #{replace}; gutter: false; toolbar: false">\n} <<
                 CGI.escapeHTML(match.pre_match) << %{</pre></div>}
    end

    def scan_until(regex)
      match = @string.match(regex)
      @string = match.post_match
      match
    end

    def flush_textile
      @output << RedCloth.new(@pending_textile).to_html << "\n"
      @pending_textile = ""
    end
  end
end

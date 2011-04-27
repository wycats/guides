require "strscan"
require "cgi"

module Guides
  class TextileTransformer
    LANGUAGES = { "ruby" => "ruby", "sql" => "sql", "javascript" => "javascript",
                  "css" => "css", "plain" => "plain", "erb" => "ruby; html-script: true",
                  "html" => "xml", "xml" => "xml", "shell" => "plain", "yaml" => "yaml" }

    NOTES =     { "CAUTION" => "warning", "IMPORTANT" => "warning", "WARNING" => "warning",
                  "INFO" => "info", "TIP" => "info", "NOTE" => "note" }

    def initialize(production=false)
      @production = production
    end

    def transform(string)
      @string = string.dup

      @output  = ""
      @pending_textile = ""

      until @string.empty?
        notes     = NOTES.keys.map {|note| "#{note}" }.join("|")
        languages = LANGUAGES.keys.join("|")

        match = scan_until /(\+(.*?)\+|<(#{languages})(?: filename=["']([^"']*)["'])?>|(#{notes}): |<(construction)>|\z)/m

        @pending_textile << match.pre_match

        if match[2]    # +foo+
          @pending_textile << "<notextile><tt>#{CGI.escapeHTML(match[2])}</tt></notextile>" if match[2]
        elsif match[3] # <language>
          flush_textile
          generate_brushes match[3], LANGUAGES[match[3]], match[4]
        elsif match[5] # NOTE:
          flush_textile
          consume_note NOTES[match[5]]
        elsif match[6] # <construction>
          flush_textile
          consume_construction
        end
      end

      flush_textile

      @output
    end

    def generate_brushes(tag, replace, filename)
      match = scan_until %r{</#{tag}>}
      @output << %{<div class="code_container">\n}
      @output << %{<div class="filename">#{filename}</div>\n} if filename
      @output << %{<pre class="brush: #{replace}; gutter: false; toolbar: false">\n} <<
                 CGI.escapeHTML(match.pre_match) << %{</pre></div>}
    end

    def scan_until(regex)
      match = @string.match(regex)
      @string = match.post_match
      match
    end

    def consume_note(css_class)
      match = scan_until /(\r?\n){2}/
      note = match.pre_match.gsub(/\n\s*/, " ")
      note = RedCloth.new(note, [:lite_mode]).to_html
      @output << %{<div class="#{css_class}"><p>#{note}</p></div>\n}
    end

    def consume_construction
      match = scan_until %r{</construction>}
      @output << TextileTransformer.new.transform(match.pre_match) unless @production
    end

    def flush_textile
      @pending_textile.gsub!(/(?<!\n)\n(?!\n)/, ' ') # Don't convert single \n to line-breaks
      @output << RedCloth.new(@pending_textile).to_html << "\n"
      @pending_textile = ""
    end
  end
end

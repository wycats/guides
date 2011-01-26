class RedCloth::TextileDoc
  def notestuff(body)
    body.gsub!(/^(IMPORTANT|CAUTION|WARNING|NOTE|INFO|TIP)[.:](.*?)(?=(\n{2}|[\r\n]{2}|\z))/m) do |m|
      css_class = $1.downcase
      css_class = 'warning' if ['caution', 'important'].include?(css_class)
      css_class = 'info' if css_class == 'tip'

      result = "<div class='#{css_class}'><p>"
      result << $2.strip
      result << '</p></div>'
      result
    end
  end

  def plusplus(body)
    body.gsub!(/\+(.*?)\+/) do |m|
      "<notextile><tt>#{$1}</tt></notextile>"
    end

    # The real plus sign
    body.gsub!('<plus>', '+')
  end
end

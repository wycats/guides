module Guides
  module Helpers
    def clickable_index
      total_guides = all_guides.inject(0) do |sum, (name, guides)|
        sum + guides.size
      end

      lgroup, rgroup, counted_guides = {}, {}, 0

      all_guides.each do |name, guides|
        if counted_guides > (total_guides / 2.0)
          rgroup[name] = guides
        else
          lgroup[name] = guides
        end

        counted_guides += guides.size
      end

      render "clickable_index", :lgroup => lgroup, :rgroup => rgroup
    end

    def is_production?
      assigns[:production]
    end

    def all_guides
      Guides.meta["index"].inject({}) do |ret, (section, items)|
        items = items.reject{|item| item['construction'] } if is_production?
        ret[section] = items unless items.empty?
        ret
      end
    end

    def guide(name, url, options = {}, &block)
      link = content_tag(:a, :href => url) { name }
      result = content_tag(:dt, link)

      if options[:work_in_progress]
        result << content_tag(:dd, 'Work in progress', :class => 'work-in-progress')
      end

      result << content_tag(:dd, capture(&block))
      result
    end

    def author(name, nick, image = 'credits_pic_blank.gif', &block)
      image = "images/#{image}" unless image =~ /^http/

      result = content_tag(:img, nil, :src => image, :class => 'left pic', :alt => name)
      result << content_tag(:h3, name)
      result << content_tag(:p, capture(&block))
      content_tag(:div, result, :class => 'author clearfix', :id => nick)
    end

    def code(&block)
      c = capture(&block)
      content_tag(:code, c)
    end

    def guide_exists?(guide)
      # Might be able to use build in view_paths methods but I couldn't figure them out - PW
      view_paths.any? do |p|
        Guides::Generator::EXTENSIONS.any?{|e| File.exist? "#{p}/#{guide["url"]}.#{e}" }
      end
    end

    def guide_link(guide)
      if guide_exists?(guide)
        link_to guide["title"], "#{guide["url"]}.html"
      else
        guide["title"]
      end
    end

    def guide_chapter_link(guide, chapter)
      if guide_exists?(guide)
        anchor = chapter.gsub(/\s/, '-').downcase
        link_to(chapter, "#{guide["url"]}.html##{anchor}")
      else
        chapter
      end
    end
  end
end

module Guides
  module Helpers
    def full_index

    end

    def clickable_index
      guides = Guides.meta["index"]

      total_guides = guides.inject(0) do |sum, (name, guides)|
        sum + guides.size
      end

      lgroup, rgroup, counted_guides = {}, {}, 0

      guides.each do |name, guides|
        if counted_guides > (total_guides / 2.0)
          rgroup[name] = guides
        else
          lgroup[name] = guides
        end

        counted_guides += guides.size
      end

      render "clickable_index", :lgroup => lgroup, :rgroup => rgroup
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
      image = "images/#{image}"

      result = content_tag(:img, nil, :src => image, :class => 'left pic', :alt => name)
      result << content_tag(:h3, name)
      result << content_tag(:p, capture(&block))
      content_tag(:div, result, :class => 'clearfix', :id => nick)
    end

    def code(&block)
      c = capture(&block)
      content_tag(:code, c)
    end
  end
end

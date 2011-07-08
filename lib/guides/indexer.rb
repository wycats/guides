require 'active_support/core_ext/object/blank'
require 'active_support/ordered_hash'
require 'active_support/core_ext/string/inflections'

module Guides
  class Indexer
    attr_reader :body, :result, :warnings, :level_hash

    def initialize(body, warnings, production = false)
      @body     = body
      @result   = @body.dup
      @warnings = warnings
      @production = production
    end

    def index
      @level_hash = process(body)
    end

    private

    def process(string, current_level=3, counters=[1])
      if @production
        # Ignore anything in construction tags
        string = string.gsub(%r{<construction>.*?</construction>}m, '')
      end

      s = StringScanner.new(string)

      level_hash = ActiveSupport::OrderedHash.new

      while s.scan_until(%r{^h(\d)(?:\((#.*?)\))?\s*\.\s*(.*)$})
        level, idx, title = s[1].to_i, s[2], s[3].strip

        if level < current_level
          # This is needed. Go figure.
          return level_hash
        elsif level == current_level
          index = counters.dup
          index[0] = sprintf('%02d', index[0])
          idx ||= '#' + title_to_idx(title)

          raise "Parsing Fail" unless @result.sub!(s.matched, "h#{level}(#{idx}). <span class='header_index'>#{index.join('.')}.</span> #{title}")

          key = {
            :title => title,
            :id => idx
          }
          # Recurse
          counters << 1
          level_hash[key] = process(s.post_match, current_level + 1, counters)
          counters.pop

          # Increment the current level
          last = counters.pop
          counters << last + 1
        end
      end
      level_hash
    end

    def title_to_idx(title)
      idx = title.strip.parameterize.sub(/^\d+/, '')
      if warnings && idx.blank?
        puts "BLANK ID: please put an explicit ID for section #{title}, as in h5(#my-id)"
      end
      idx
    end
  end
end

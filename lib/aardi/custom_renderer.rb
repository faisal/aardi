# frozen_string_literal: true

module Aardi
  class CustomRenderer < Redcarpet::Render::HTML
    include Redcarpet::Render::SmartyPants

    HEADER_SQUEEZE = /&#.*?;|&quot;|[^a-z0-9\-_]/

    def header(text, header_level)
      "<h#{header_level} id=\"#{header_id(text)}\">#{text.squeeze(' ')}</h#{header_level}>"
    end

    def link(link, title, content)
      link_title = " title=\"#{title}\"" if title
      "<a href=\"#{link}\"#{link_title}>#{content}</a>"
    end

    def reset
      ids.clear
    end

    private

    def header_id(text)
      stub_id = header_stub_id(text)
      count = ids[stub_id] += 1

      return "#{stub_id}-#{count - 1}" if count > 1

      stub_id
    end

    def header_stub_id(text)
      text.downcase.strip.tr(' ', '-').gsub(HEADER_SQUEEZE, '').squeeze('-')
    end

    def ids
      @ids ||= Hash.new(0)
    end
  end
end

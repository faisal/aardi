# frozen_string_literal: true

module Aardi
  class Sitemap
    # :reek:NestedIterators
    def content
      sitemap = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do
        urlset(xmlns: 'http://www.sitemaps.org/schemas/sitemap/0.9') do |urlset|
          urls.each do |path, details|
            url_details(path, details, urlset)
          end
        end
      end

      sitemap.to_xml
    end

    def record_mtime(path, path_mtime)
      return unless urls.key?(path) && path_mtime

      update_mtime(path, path_mtime)
    end

    def render(renderer)
      source = Content.new(content)
      FileTarget.new(source, target_path, renderer).write
    end

    def target_path = './sitemap.xml'

    def update_mtime(path, path_mtime)
      urls[path][:lastmod] = path_mtime.iso8601
    end

    # Absent a block variable on Nokogiri::XML::Builder.new, this
    # is called by the builder, not sitemap itself, and must be public.
    # :reek:FeatureEnvy
    def url_details(path, details, urlset)
      missing_path(path) unless File.exist?("./#{path}")

      urlset.url do
        details.slice(:loc, :lastmod, :changefreq).each do |node, value|
          urlset.public_send node, value
        end
      end
    end

    def urls
      @urls ||= Aardi.config[:sitemap_entries].to_h { |path, cf| [path, url_values(path, cf)] }
    end

    private

    def missing_path(path)
      puts("FATAL: #{path} missing")
      exit
    end

    def url_values(path, changefreq)
      { loc: "#{Aardi.config[:site_url]}#{path}", changefreq: }
    end
  end
end

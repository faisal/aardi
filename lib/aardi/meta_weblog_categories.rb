# frozen_string_literal: true

require 'aardi'

module Aardi
  # Maps Aardi tags onto the category structs MarsEdit expects, and reads
  # category names back out of the structs MarsEdit sends.
  class MetaWeblogCategories
    def assigned(tags)
      tags.map { |tag| { 'categoryName' => tag, 'isPrimary' => false } }
    end

    # :reek:FeatureEnvy
    def from_struct(struct)
      categories = Array(struct['categories']).map(&:to_s)
      return categories unless categories.empty?

      keywords = struct['mt_keywords']
      keywords ? keywords.split(',').map(&:strip) : []
    end

    def list(records)
      records.flat_map(&:tags).uniq.sort.map { |tag| struct(tag) }
    end

    def names(categories)
      categories.map { |category| name(category) }
    end

    private

    def name(category)
      return category unless category.is_a?(Hash)

      category['categoryName'] || category['categoryId']
    end

    def struct(tag)
      { 'categoryId' => tag, 'categoryName' => tag, 'title' => tag, 'description' => tag,
        'htmlUrl' => "#{Config[:site_url]}/#{Config.fetch(:blog_tags_path)}/#{tag}/", 'rssUrl' => '' }
    end
  end
end

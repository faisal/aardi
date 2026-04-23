# frozen_string_literal: true

require 'spec_helper'

class AtomFeedSpec < Minitest::Spec
  def posts = [StubPost.new(Time.now)]

  describe Aardi::ATOMFeed do
    before do
      setup_config
    end

    def make_feed(posts = [])
      Aardi::ATOMFeed.new(posts, config: Aardi.config, ledger: Aardi.ledger)
    end

    describe '#target_path' do
      it 'is ./index.xml' do
        _(make_feed.target_path).must_equal './index.xml'
      end
    end

    describe '#content' do
      let(:ns) { { 'atom' => 'http://www.w3.org/2005/Atom' } }

      it 'produces valid XML' do
        doc = Nokogiri::XML(make_feed(posts).content)

        _(doc.errors).must_be_empty
      end

      it 'includes the Atom feed namespace' do
        content = make_feed(posts).content

        _(content).must_include 'http://www.w3.org/2005/Atom'
      end

      it 'includes the site title in the feed title element' do
        doc = Nokogiri::XML(make_feed(posts).content)

        _(doc.at_xpath('//atom:title', ns).text).must_equal 'Test Site'
      end

      it 'includes the author name in the author element' do
        doc = Nokogiri::XML(make_feed(posts).content)

        _(doc.at_xpath('//atom:author/atom:name', ns).text).must_equal 'Test Author'
      end

      it 'includes an entry for each post' do
        posts = [StubPost.new(Time.now, title: 'Post One'), StubPost.new(Time.now, title: 'Post Two')]
        doc = Nokogiri::XML(make_feed(posts).content)
        titles = doc.xpath('//atom:entry/atom:title', ns).map(&:text)

        _(titles.length).must_equal 2
        _(titles).must_include 'Post One'
        _(titles).must_include 'Post Two'
      end

      it 'includes the feed URL pointing to index.xml' do
        doc = Nokogiri::XML(make_feed(posts).content)
        href = doc.at_xpath("//atom:link[@rel='self']/@href", ns).value

        _(href).must_equal 'http://example.com/index.xml'
      end

      it 'includes post titles and URLs in entries' do
        post = StubPost.new(Time.now, title: 'My Entry', name: 'my-entry')
        doc = Nokogiri::XML(make_feed([post]).content)
        entry = doc.at_xpath('//atom:entry', ns)

        _(entry.at_xpath('atom:title', ns).text).must_equal 'My Entry'
        _(entry.at_xpath('atom:link/@href', ns).value).must_equal post.url
      end
    end
  end
end

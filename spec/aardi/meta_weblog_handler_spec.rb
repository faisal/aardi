# frozen_string_literal: true

require 'spec_helper'
require 'aardi/post_store'
require 'aardi/media_store'
require 'aardi/meta_weblog_handler'

# :reek:TooManyInstanceVariables
class MetaWeblogHandlerSpec < Minitest::Spec
  describe Aardi::MetaWeblogHandler do
    before do
      @tmpdir = Dir.mktmpdir
      @original_dir = Dir.pwd
      Dir.chdir(@tmpdir)
      FileUtils.mkdir_p('posts')
      setup_config(template_path: File.join(SpecHelpers::SAMPLES_DIR, 'minimal_template.html'),
                   blog_posts_path: './posts',
                   content_hashes_path: File.join(@tmpdir, 'hashes.txt'))
      make_renderer
      @store = Aardi::PostStore.new
      @renders = 0
      @handler = Aardi::MetaWeblogHandler.new(store: @store, media: Aardi::MediaStore.new,
                                              on_change: -> { @renders += 1 })
    end

    after do
      Dir.chdir(@original_dir)
      FileUtils.rm_rf(@tmpdir)
    end

    # :reek:LongParameterList
    def new_post(title: 'Hello', body: "World.\n", categories: [], date: Time.utc(2024, 1, 5, 9, 0, 0))
      @handler.new_post({ 'title' => title, 'description' => body,
                          'categories' => categories, 'dateCreated' => date }, true)
    end

    describe '#users_blogs' do
      it 'returns a single blog described by the site config' do
        blogs = @handler.users_blogs

        _(blogs.length).must_equal 1
        _(blogs.first['blogName']).must_equal 'Test Site'
        _(blogs.first['url']).must_equal 'http://example.com'
      end
    end

    describe '#new_post' do
      it 'creates a resolvable post and triggers a render' do
        postid = new_post(title: 'First', body: "Body.\n")

        _(@store.find(postid).title).must_equal 'First'
        _(@renders).must_equal 1
      end

      it 'maps categories onto Aardi tags' do
        postid = new_post(categories: %w[ruby web])

        _(@store.find(postid).tags).must_equal %w[ruby web]
      end
    end

    describe '#get_post' do
      it 'returns a struct with the body as description and a permalink' do
        postid = new_post(title: 'Readable', body: "Some text.\n")
        struct = @handler.get_post(postid)

        _(struct['title']).must_equal 'Readable'
        _(struct['description']).must_equal "Some text.\n"
        _(struct['dateCreated']).must_be_kind_of Time
        _(struct['link']).must_include 'http://example.com/blog/2024/01/05/'
      end
    end

    describe '#recent_posts' do
      it 'returns post structs newest-first, limited to the count' do
        new_post(title: 'Old', date: Time.utc(2024, 1, 1, 0, 0, 0))
        new_post(title: 'New', date: Time.utc(2024, 6, 1, 0, 0, 0))

        titles = @handler.recent_posts(5).map { |struct| struct['title'] }

        _(titles).must_equal %w[New Old]
      end
    end

    describe '#edit_post' do
      it 'updates the post, preserves creation, and triggers a render' do
        postid = new_post(title: 'Before', body: "old\n")
        @renders = 0
        result = @handler.edit_post(postid, { 'title' => 'After', 'description' => "new\n",
                                              'categories' => [] }, true)
        record = @store.find(postid)

        _(result).must_equal true
        _(record.title).must_equal 'After'
        _(record.creation).must_equal Time.utc(2024, 1, 5, 9, 0, 0)
        _(@renders).must_equal 1
      end
    end

    describe '#delete_post' do
      it 'removes the post and triggers a render' do
        postid = new_post
        @renders = 0
        result = @handler.delete_post(postid)

        _(result).must_equal true
        _(File.exist?(File.join('posts', postid))).must_equal false
        _(@renders).must_equal 1
      end
    end

    describe '#categories' do
      it 'returns a category struct for each distinct tag across posts' do
        new_post(categories: %w[ruby], date: Time.utc(2024, 1, 1, 0, 0, 0))
        new_post(categories: %w[web ruby], date: Time.utc(2024, 2, 1, 0, 0, 0))

        names = @handler.categories.map { |cat| cat['categoryName'] }

        _(names.sort).must_equal %w[ruby web]
      end
    end

    describe '#new_media_object' do
      it 'saves the uploaded bytes and returns a url' do
        result = @handler.new_media_object('name' => 'pic.png', 'bits' => 'RAWBYTES')

        _(result['url']).must_equal 'http://example.com/media/pic.png'
        _(File.binread(File.join('media', 'pic.png'))).must_equal 'RAWBYTES'
      end
    end

    describe '#supported_methods' do
      it 'advertises the core MetaWeblog and MovableType methods' do
        methods = @handler.supported_methods

        _(methods).must_include 'metaWeblog.newPost'
        _(methods).must_include 'metaWeblog.getRecentPosts'
        _(methods).must_include 'blogger.deletePost'
      end
    end

    describe 'category and keyword extraction' do
      it 'falls back to comma-separated mt_keywords when no categories are given' do
        postid = @handler.new_post({ 'title' => 'K', 'description' => "b\n",
                                     'mt_keywords' => 'alpha, beta',
                                     'dateCreated' => Time.utc(2024, 1, 5, 9, 0, 0) }, true)

        _(@store.find(postid).tags).must_equal %w[alpha beta]
      end
    end

    describe 'open authentication' do
      it 'ignores the supplied credentials' do
        postid = new_post(title: 'NoAuth')

        _(@store.find(postid).title).must_equal 'NoAuth'
      end
    end
  end
end

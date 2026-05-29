# frozen_string_literal: true

def api_render_hook
  lambda do
    Aardi::Site.new.render
  rescue StandardError => e
    warn(e.message)
  end
end

# rubocop:disable Metrics/AbcSize, Metrics/MethodLength
def api_servlet(handler)
  servlet = XMLRPC::WEBrickServlet.new
  {
    'blogger.getUsersBlogs' => ->(_appkey, _user, _pass) { handler.users_blogs },
    'blogger.deletePost' => ->(_appkey, postid, _user, _pass, _publish) { handler.delete_post(postid) },
    'metaWeblog.getRecentPosts' => ->(_blogid, _user, _pass, num) { handler.recent_posts(num) },
    'metaWeblog.getPost' => ->(postid, _user, _pass) { handler.get_post(postid) },
    'metaWeblog.newPost' => ->(_blogid, _user, _pass, struct, pub) { handler.new_post(struct, pub) },
    'metaWeblog.editPost' => ->(postid, _user, _pass, struct, pub) { handler.edit_post(postid, struct, pub) },
    'metaWeblog.getCategories' => ->(_blogid, _user, _pass) { handler.categories },
    'metaWeblog.newMediaObject' => ->(_blogid, _user, _pass, struct) { handler.new_media_object(struct) },
    'mt.getCategoryList' => ->(_blogid, _user, _pass) { handler.categories },
    'mt.getPostCategories' => ->(postid, _user, _pass) { handler.post_categories(postid) },
    'mt.setPostCategories' => ->(postid, _user, _pass, cats) { handler.set_post_categories(postid, cats) },
    'mt.supportedMethods' => -> { handler.supported_methods },
    'mt.supportedTextFilters' => -> { [] }
  }.each { |name, callable| servlet.add_handler(name, &callable) }
  servlet
end
# rubocop:enable Metrics/AbcSize, Metrics/MethodLength

desc('Run a MarsEdit-compatible XML-RPC API server')
task api: [:load_config] do
  require 'webrick'
  require 'xmlrpc/server'
  require 'aardi/post_store'
  require 'aardi/media_store'
  require 'aardi/meta_weblog_handler'

  port = 3000
  handler = Aardi::MetaWeblogHandler.new(store: Aardi::PostStore.new,
                                         media: Aardi::MediaStore.new, on_change: api_render_hook)
  puts("http://localhost:#{port}/xmlrpc")

  server = WEBrick::HTTPServer.new(Port: port)
  server.mount('/xmlrpc', api_servlet(handler))
  server.mount('/', api_servlet(handler))

  trap('INT') { server.shutdown }
  server.start
end

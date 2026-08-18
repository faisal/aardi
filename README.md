# Aardi

Aardi is a library for static site generation, and number of [`rake`](https://ruby.github.io/rake/) tasks to use it as a static site generator immediately.

Aardi implements as few features as reasonably possible.

## Getting started

1. Create a Gemfile with `aardi`, or add `aardi` to one you already have:

   ```
   source "https://rubygems.org"
   gem "aardi"
   ```

2. Add `aarti` to your Rakefile:

   ```
   require "bundler/setup"
   Bundler.require(:default)
   require "aardi/tasks"
   ```

3. `bundle install`

4. Initialize the site: `rake init`

5. Edit config.yml and .template.html to suit your needs.

6. Create .md files where you want .html files to appear.

7. Tun `rake render` to generate the site.

8. Run `rake -T` to see available commands.


## Details

- There is no CLI but `rake`. The rake tasks are:
  - General commands:
    - `rake init` scaffolds a new aardi site.
    - `rake render` renders all the files (unless nothing has changed)
    - `rake server` runs a local preview server
    - `rake homepage` visit the published site
  - Blog commands:
    - `rake new` creates a new empty blog post and reports the path
    - `rake recent` lists recent blog post dates, source paths, and titles
  - Utility commands:
    - `rake now` produces an Updated header with current timestamp, for use in blog post metadata
    - `rake fixtimes` fixes the timestamps of files based on the latest `git` modification timestamp.
- All .md files will be rendered to .html files in the same directory, except:
  - Anything in the `files_to_exclude` config.
  - Blog post files are rendered into the blog hierarchy as posts on the creation date, and as content within day and month pages.
    - _Note:_ list the blog path and posts path in `files_to_exclude` to prevent them being rendered in place as well. This is in the default config.yml.
    - The blog will also have sub-blogs for any and all keywords you add to a Tags: directive on posts.
- The title of the page is extracted from the first line of the .md file content. You can override this with a Title: directive in the metadata.
- Pages can have metadata, which is a key-value block followed by an empty line and then `----` on a line by itself. See the results of `rake new` for a basic example. Useful keywords there are:
  - `Creation:` The creation date and time for a blog posts.
  - `Updated:` The updated date and time for a blog post. You can get this information easily with `rake now`.
  - `Title:` The page title, overriding what was in the first line of the content.
  - `Description:` The page description, for the HTML `<meta name="description" ...` block.
  - `Tags:` a space-delimited list of keywords for the post
  - `Draft:` indicates this is a draft blog post. Draft post pages will publish but the post will not be included in day, month, year, or archive pages.
- Aardi won't write out a file if the content is unchanged.
- Aardi records checksums of rendered files in .content_hashes.txt, and won't write a file whose checksum maches its existing checksum. Deleting the .content_hashes.txt file may result in a more complete render pass on the next run.
- I will attempt to follow [semver](https://semver.org) numbering.

## Configuration

Configure your settings in the config.yml file at the top level of your site. configuration values are:

- site_title: The title front-matter for every page on your site.
- site_url: The URL at which you'll be posting this.
- site_author: The author's name.
- files_to_exclude: An array or list of the .md files to not render in-place. This should include the directory where you render your blog (see `blog_archive_path`, below), the directory where you store your blog posts (see `blog_posts_path` below), and any other markup files you don't want rendered to heml (such as an `AGENTS.md`, if you have one.)
- ignore_orphans: An array of paths which will not be listed as orphan HTML files. This is useful if you are have raw .html files that you don't manage through Aardi in the path.
- template_path: The template file that is the basis for all rendered pages on the site.
- blog_archive_path: The name of the directory for the rendered blog.
- blog_posts_path: The name of the directory with the source files for the blog.
- blog_feed_posts: The number of recent posts to include in the ATOM and JSON feeds.
- blog_recent_posts: The number of posts `rake recent` should report
- blog_archive_title: The title of the blog's archive page.
- blog_home_title: The title of the blog's home page.
- blog_home_posts: How many posts to list on the blog's home page.
- blog_tags_path: The name of the directory in which to store blog tag sub-blogs.
- sitemap_entries: A dictionary of paths and how frequently the sitemap should indicate those paths are refreshed.
- markup_options: A dictionary of true/false markup options for the renderer to follow. Those include:
  - autolink: automatically make URLS in text into clickable links.
  - fenced_code_blocks: support "```" style fenced code blocks
  - footnotes: support markdown footnotes
  - no_intra_emphasis: prevent mid-word emphasis
  - strikethrough: support ~~ strikethrough
  - superscript: support superscript
  - tables: support tables
- content_hashes_path: Where to store the cache of page checksums to skip unecessary re-rendering.


## Contributing

- Details TBD, but PRs will be considered if I have the time.
- I prioritize simplicity, performance, and a highly conservative approach to runtime dependencies.

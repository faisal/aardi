# Aardi

Aardi is a static site generator.

It is a Ruby gem that provides a number of `rake` tasks for rendering markdown files into html pags.

## Getting started

1. Create a Gemfile:

   ```
   source "https://rubygems.org"
   gem "aardi"
   ```

2. Create a Rakefile:

   ```
   require "bundler/setup"
   Bundler.require(:default)
   require "aardi/tasks"
   ```

3. Initialize the site: `rake init`

4. Edit config.yml and .template.html to suit your needs.

5. Create .md files where you want .html files to appear.

6. Tun `rake render` to generate the site.

5. Run `rake -T` to see available commands.


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
- The title of the page is extracted from the first line of the .md file content. You can override this with a Title: directive in the metadata.
- Pages can have metadata, which is a key-value block followed by an empty line and then `----` on a line by itself. See the results of `rake new` for a basic example. Useful keywords there are:
  - `Creation:` The creation date and time for a blog posts.
  - `Updated:` The updated date and time for a blog post. You can get this information easily with `rake now`.
  - `Title:` The page title, overriding what was in the first line of the content.
  - `Description:` The page description, for the HTML `<meta name="description" ...` block.

## Contributing

- Details TBD, but PRs will be considered if I have the time.
- I prioritize simplicity, performance, and a highly conservative approach to runtime dependencies.

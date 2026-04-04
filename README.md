# Aardi

Aardi is a static site generator.

## Getting started

1. Create a Gemfile:

  ```
  source "https://rubygems.org"
  gem "aardi", path: "../aardi"

  ```

2. Create a Rakefile:

  ```
  require "bundler/setup"
  Bundler.require(:default)
  require "aardi/tasks"
  ```

3. Initialie the site:

  `rake init`

4. Edit config.yml and .template.html to suit your needs.

5. Create .md files where you want .html files to appear.

6. Tun `rake render` to generate the site.

5. Run `rake -T` to see available commands.


## Details

- Any .md files will be rendered to a .html file in the same place.
- Unless it's in the blog posts, in which case it will be rendered as a blog post. Use `rake new` to create a new post, then write in the file.
- The title of the page is extracted from the first line of the .md file content. You can override this with a Title: directive in the metadata.
- Pages can have metadata, which is a key-value block followed by an empty line and then `----` on a line by itself. See the results of `rake new` for a basic example. Useful keywords there are:

  `Creation:`
  : The creation date and time for a blog posts.

  `Updated:`
  : The updated date and time for a blog post. You can get this information easily with `rake now`.

  `Title:`
  : The page title, overriding what was in the first line of the content.

  `Description:`
  : The page description, for the HTML `<meta name="description" ...` block.


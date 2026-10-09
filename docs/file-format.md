# Source File Structure and Content Rules

This document describes the structure and content rules for `.md` files in this repository.

## File Format Overview

Every `.md` file is split into two sections — optional YAML frontmatter and markdown content — separated by a four-dash delimiter. The parsing is performed in `AbstractPageSupport#parse_source` using Ruby's `String#rpartition`:

```
[YAML frontmatter]

----
[Markdown content]
```

The separator is the literal string `\n----\n` (a newline, four hyphens, a newline). The blank line before `----` is a convention, not a requirement. `rpartition` splits at the *last* occurrence, so the markdown content must not contain a line that is exactly `----`. If it does, the split happens there, and everything above that line (including the real frontmatter and part of the content) is parsed as YAML. Use a different horizontal rule (such as `***` or `-----`) in the content.

If no separator is present (as with `404.md`), `rpartition` returns an empty string for the first part, and `YAML.safe_load("")` yields `nil`, which is coerced to `{}`. The entire file content then becomes the markdown body. This means frontmatter is optional — a file with no `----` separator is treated as pure content with no metadata. Frontmatter that parses to something other than a YAML mapping is also treated as `{}`.

## Frontmatter Fields

Frontmatter is parsed by `Metadata` with `YAML.safe_load` with `Time` as a permitted class, so timestamps are deserialized directly into Ruby `Time` objects.

### Recognized fields

| Field         | Type   | Used by        | Purpose |
|---------------|--------|----------------|---------|
| `Creation`    | `Time` | `Post`         | The post's publication date. Determines the output path (`{blog_archive_path}/YYYY/MM/DD/{name}.html`) and sort order. **Required for blog posts**; a post without it raises `<path>: missing Creation metadata`. |
| `Updated`     | `Time` | `Post`         | Last-modified date. Falls back to `Creation` if absent. Used in ATOM and JSON feeds. |
| `Title`       | String | `AbstractPageSupport`, `Template` | Explicit page/post title. If omitted, the title is extracted from the first line of content by stripping any leading `#+ ` heading prefix. |
| `Description` | String | `Template`     | Sets the `content` of the template's `<meta name="description">` tag. If absent, the template's own `content` value is kept. Has no effect if the template has no such tag. |
| `Tags`        | String | `Post`, `Tags`, `TagBlog` | A space-delimited list of tags, e.g. `Tags: covid science`. The list is split on whitespace and sorted. Each tag gets a sub-blog (see [Tags](#tags)). Must be a string, not a YAML list. |
| `Draft`       | any    | `Post`, `Blog` | Marks a post as a draft (see [Drafts](#drafts)). Only the presence of the key matters: `Draft: false` also marks a draft. |

Any other key is ignored, and the render prints a warning such as:

```
Ignored unknown declaration 'Foo' in posts/r/1651270771.md
```

### Canonical new-post template (from `rake new`)

The `new` task generates this skeleton:

```
Creation: 2022-04-29T22:19:31Z

----
### title

[source](url): "excerpt"
```

This reveals the expected blog post pattern: a `Creation` timestamp, the `----` separator, a level-3 heading as the title, and a link-plus-quote body.

### Example: blog post with minimal frontmatter

```
Creation: 2022-04-29T22:19:31Z

----
### The "Paxlovid Rebound" Problem is Real

[Buzz Hollander MD](https://example.com): "Quote excerpt here."
```

### Example: blog post with tags and an update time

```
Creation: 2022-04-29T22:19:31Z
Updated: 2022-04-30T08:00:00Z
Tags: covid science

----
### The "Paxlovid Rebound" Problem is Real

[Buzz Hollander MD](https://example.com): "Quote excerpt here."
```

### Example: page with Description and no Creation

```
Description: The easiest way to reach Faisal is by email.

----
# Contacting Faisal

Page body content here.
```

### Example: page with no frontmatter at all

```
# No Such File (any more?)

The page or file you linked to does not exist.
```

## Two Content Types: Pages and Posts

The codebase distinguishes between **Pages** and **Posts**. Both share the same file format, but they are discovered and rendered differently.

### Pages

The code recursively walks the directory tree starting from the site's top level, and collects every `.md` file (excluding paths listed in `config.yml`'s `files_to_exclude`). Pages are rendered to HTML in-place: `contact.md` becomes `contact.html`, `docs/emacs.md` becomes `docs/emacs.html`.

Pages may have `Title` and `Description` metadata. They do not need `Creation`.

### Posts

Post sources are stored in the directory named by the `blog_posts_path` config value (`posts` by default). Every `.md` file at any depth under that directory is a post. Posts **must** have a `Creation` field, with no fallback, and the value is used for date arithmetic, URL generation, and sorting.

The `rake new` task puts each new post in a single-character, base-36 bucket subdirectory (e.g., `posts/r/`, `posts/0/`). This keeps directory sizes manageable. The bucket is only a convention of `rake new`; the code does not require it.

Filenames can be any string. The `rake new` task creates a file name based on the UNIX timestamp (e.g. `1651270771.md`), but you can use any valid ASCII string (e.g. `top-ten-dying-game-genres-any-of.md`). The filename (minus extension) is used for the HTML file name, and the last segment of the output URL.

Posts are sorted by `Creation` date. The output path is `{blog_archive_path}/YYYY/MM/DD/{name}.html` (`blog_archive_path` is `blog` by default), derived from the `Creation` timestamp and the filename. Rendered posts are also included in the blog home page, the daily, monthly and yearly archives, and the feeds.

Put the posts directory and the blog archive directory in `files_to_exclude`, so the post sources are not also rendered as pages. The default `config.yml` does this.

Each post's rendered content automatically gets a bookmark line appended. If the post has tags, a link to each tag's sub-blog follows the bookmark link:

```html
<div><span class="bookmark">[<a href="{url}">bookmark</a>] <a href="{site_url}/{blog_tags_path}/{tag}/">{tag}</a>, ...</span></div>
```

### Tags

Each tag in a post's `Tags` field gets a sub-blog at `{blog_tags_path}/{tag}/` (`blog_tags_path` is `tags` by default). A sub-blog has its own home page, archive, ATOM feed and JSON feed, which contain only the posts with that tag. The `{blog_tags_path}/index.html` page lists all tags with their post counts, and each tag's feeds are listed in `.well-known/feed-menu.json`.

### Drafts

A post with a `Draft` key is a draft. A draft post is still rendered to its own page at its normal output path. But it is not included in the blog home page, the day, month, year, or archive pages, the feeds, or the tag sub-blogs. `rake drafts` lists all draft posts.

## Markdown Rendering

Content is rendered using **Redcarpet** with a `CustomRenderer` that extends `Redcarpet::Render::HTML` and includes `SmartyPants` for typographic punctuation (smart quotes, em-dashes, etc.).

### Redcarpet extensions (from `config.yml`)

The extensions are set by the `markup_options` dictionary in the site's `config.yml`. The default `config.yml` from `rake init` sets:

- `fenced_code_blocks` — triple-backtick code blocks
- `footnotes` — `[^1]` style footnotes
- `no_intra_emphasis` — underscores inside words aren't treated as emphasis
- `strikethrough` — `~~deleted~~` syntax
- `superscript` — `^superscript` syntax
- `tables` — pipe-delimited table syntax
- `autolink` is **disabled** — URLs must be explicitly wrapped in link syntax

### Custom header processing

`CustomRenderer#header` generates header tags with auto-generated `id` attributes for linking. The algorithm (in `header_stub_id`): lowercase and strip the text, replace spaces with hyphens, remove HTML entities and all characters other than `a-z`, `0-9`, `-` and `_`, then squeeze consecutive hyphens. Duplicate IDs within a page get a numeric suffix (`-1`, `-2`, etc.).

Example: `### The immunology of long COVID` renders as `<h3 id="the-immunology-of-long-covid">The immunology of long COVID</h3>`.

### Custom link processing

`CustomRenderer#link` renders standard anchor tags, including an optional `title` attribute only when one is provided.

## Title Resolution

The priority is: use the explicit `Title` metadata field if present; otherwise take the first line of the markdown content and strip any leading heading markers (`#`, `##`, `###`, etc. followed by a space). This means for a post whose first line is `### Some Heading`, the derived title is `Some Heading`.

## Feed Generation

The most recent posts (controlled by `blog_feed_posts` in config) are included in two feed formats. The main blog's feeds are at the site root; each tag sub-blog has its own feeds at `{blog_tags_path}/{tag}/`.

### Feed snippet content

`Renderer#markup_feed_snippet` strips a leading level-3 heading and the blank lines after it from the post's source content before rendering:

```ruby
markup(content.sub(/\A(### .*\n)?\n+/, '')).strip
```

This means the heading that serves as the post title is removed from the feed body, leaving only the substantive content. Only a `### ` heading is removed; a `#` or `##` heading stays in the feed body. The bookmark line is not included in the feed.

### ATOM feed (`index.xml`)

Uses `Creation` for `<published>` and `Updated` for `<updated>`.

### JSON Feed 1.1 (`index.json`)

Uses `Creation` for `date_published`. Includes `date_modified` only when `Updated` differs from `Creation`.

## Incremental Build

The `ContentHashes` system records a CRC32 hash of each file's full rendered output in `.content_hashes.txt` (the `content_hashes_path` config value). A file is written if it does not exist, or if its output hash differs from the recorded hash and the new output differs from what's on disk. This means editing a `.md` file's content or metadata, or the template, will trigger a rebuild of the affected files, but a no-op change will not produce a new file.

## Summary of Rules

1. Use `\n----\n` as the separator between YAML frontmatter and markdown content. Do not put a line that is exactly `----` in the content.
2. Frontmatter is optional for pages, but posts **must** include `Creation` as an ISO 8601 timestamp.
3. The documented fields are `Creation`, `Updated`, `Title`, `Description`, `Tags`, and `Draft`. Other keys are ignored with a warning.
4. If `Title` is omitted, the first line of content is used (with heading markers stripped).
5. `Tags` is a space-delimited string. Each tag gets a sub-blog under `blog_tags_path`.
6. Any `Draft` key makes a post a draft, which renders but is left out of the home page, archives, feeds and tags.
7. Markdown extensions come from `markup_options`. The defaults support fenced code blocks, footnotes, strikethrough, superscript, and tables, but not autolinking.
8. Post files go anywhere under `blog_posts_path`; page files live anywhere else in the tree that is not in `files_to_exclude`.
9. Post filenames become the final URL path segment.

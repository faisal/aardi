# v2.1.0

- Add support for draft posts.

# v2.0.2

- No longer enable YJIT by default.
  YJIT is still supported, so you can enable it in calling code or via the `RUBY_YJIT_ENABLE` environment variable if desired.
- For future backward compatibility, added allowed keywords that we expect to use in v2.1.

# v2.0.1

- Fixed mention of incorrect version in README.md.

# v2.0.0

- Support post tags, and automatic reation of sub-blogs based on their `Tags:` directive
- API removals or changes:
  - Intantiation of a Blog object no longer takes a posts path.
    Intantiate the Blog and then build its posts list instead.
  - A new Render class deals with walking the content trees, recursively tracking site manipulation, updating content hashes, and reporting on any orphans.
    Aardi.renderer is a module-level singleton of the renderer.
    With this, the Ledger class is removed.
  - Config is now in a class singleton.
    It raises when selecting for a missing key.
  - Post no longer has #day, #month, and #year methods.
    Use creation.day, creation.month, and creation.year instead.

# v1.0.0

- Orphan files warning now goes to STDERR rather than STDOUT
- Switched from Standard Ruby to plain Rubocop for linting.
- Add ruby-lsp to development dependies, for use in development.

# v0.9.2

- Lowered minimum Ruby to 3.3.

# v0.9.1

- Added this changelog.
- Added source listing to gem metadata.

# v0.9.0

- First publication.

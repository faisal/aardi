# v2.0.0

- Support post tags, and automatic reation of sub-blogs based on their `Tags:` directive
- API removals or changes:
  - Intantiation of a Aardi::Blog object no longer takes a posts path. Intantiate the Blog and then build its posts list instead.
  - Post no longer has #day, #month, and #year methods. use creation.day, creation.month, and creation.year instead.

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

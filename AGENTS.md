# Aardi

This is a Ruby gem that provides a library and Rake tasks to support static site generation.

## Development Workflow

ALWAYS use a behavior driven development flow when changing code:

  1. Ask the developer to approve or correct the design approach.
  2. Add new minitest specs in the spec/ dir to describe how the desired change will work.
     a. Ask the developer to approve or correct the specs.
     b. Run the specs (`bundle exec rake spec`) to confirm they fail because the desired behavior isn't yet implemented.
  3. Implement the new behavior.
     a. Add or change code in lib/ to implement the new behavior.
     b. Re-run the specs (`bundle exec rake spec`) and confirm they now pass.
       - If they do not pass, correct the new code.
         - If it appears they do not pass because the specs themselves are incorrect, confirm ask the developer how to proceed.
       - Also confirm no other specs regressed.
        - If other functionality regressed, ask the developer how to proceed.
  4. Confirm that `bundle exec rubocop` and `bundle exec reek` both pass cleanly. If not, update the code so they pass.
  5. Once all of the above are done, prepare a commit message, and ask the user to commit the change if they approve.

NEVER commit unless directed to do so by the developer.

## Tools

- This library depends on Ruby of at least the version specified in s.required_ruby_version = '>= 3.3' in aardi.gemspec, or higher. If not sure which Ruby to use for development, review the user's environment and checck if chruby or rbenv provide a suitable Ruby. Do not use the version of Ruby provied by macOS, as it is very old and Aardi will not work with it.
- Use Minitest::Spec as configured by the project (`bundle exec rake spec`). Do not use RSpec unless the project specifies it in the Rakeifle and in the .gemspec or the Gemfile -- and if so then confirm the developer does want to use Rspec.
- Use Rubocop (`bundle exec rubocop`) and Reek (`bundle exec reek`) to monitor code cleanliness. These must always pass cleanly before committing.
- Use Flog (for example, `bundle exec flog -da lib`) to monitor for complexity when the developer requires.
- Use hyperfine (for example, `hyperfine -w 1 -r 16 rake`) to confirm process runtime.
- Prefer use of an LSP (for example Ruby-LSP) over `grep` or `read` when navigating code.

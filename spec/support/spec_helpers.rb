# frozen_string_literal: true

module SpecHelpers
  SAMPLES_DIR = File.expand_path("../samples", __dir__)

  # Write a minimal Markdown post file to dir and return its path.
  # :reek:LongParameterList
  def make_post_file(dir, creation: Time.utc(2024, 1, 15, 12, 0, 0), title: "Test Post", name: "test-post")
    content = "Creation: #{creation.iso8601}\n\n----\n### #{title}\n\nContent.\n"
    path = File.join(dir, "#{name}.md")
    File.write(path, content)
    path
  end

  # Absolute path to a file in spec/samples/.
  def sample_path(filename)
    File.join(SAMPLES_DIR, filename)
  end

  # Load a minimal config into Aardi.config. Resets state first.
  # Optionally merge overrides (string keys).
  # :reek:TooManyStatements
  def setup_config(overrides = {})
    Aardi.reset!
    base = YAML.safe_load_file(File.join(SAMPLES_DIR, "minimal_config.yml"))
    config_data = base.merge(overrides.transform_keys(&:to_s))
    Tempfile.create(["config", ".yml"]) do |file|
      file.write(config_data.to_yaml)
      file.flush
      Aardi.config.load(file.path)
    end
  end

  # Populate Aardi.ledger with renderers, template, content_hashes, and html_files.
  # Requires setup_config to have been called first.
  # :reek:ControlParameter
  # :reek:DuplicateMethodCall
  # :reek:TooManyStatements
  def setup_ledger(template_html: nil)
    custom_renderer = Aardi::CustomRenderer.new
    markup_opts = Aardi.config[:markup_options] || {}
    markdown_renderer = Redcarpet::Markdown.new(custom_renderer, markup_opts)

    Aardi.ledger[:custom_renderer] = custom_renderer
    Aardi.ledger[:markdown_renderer] = markdown_renderer
    Aardi.ledger[:content_hashes] = Aardi::ContentHashes.new("/nonexistent_test_hashes")
    Aardi.ledger[:html_files] = Set.new

    html = template_html || File.read(File.join(SAMPLES_DIR, "minimal_template.html"))
    Tempfile.create(["template", ".html"]) do |file|
      file.write(html)
      file.flush
      Aardi.ledger[:template] = Aardi::Template.new(file.path)
    end
  end
end

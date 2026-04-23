# frozen_string_literal: true

module SpecHelpers
  SAMPLES_DIR = File.expand_path('../samples', __dir__)

  def page_by_sample_path(filename, ledger: Aardi::Ledger.new)
    Aardi::Page.new sample_path(filename), ledger:
  end

  def sample_path(filename)
    File.join(SAMPLES_DIR, filename)
  end

  # :reek:TooManyStatements
  def setup_config(overrides = {})
    base = YAML.safe_load_file(File.join(SAMPLES_DIR, 'minimal_config.yml'))
    config_data = base.merge(overrides.transform_keys(&:to_s))
    config = nil
    Tempfile.create(['config', '.yml']) do |file|
      file.write(config_data.to_yaml)
      file.flush
      config = Aardi::Config.new(file.path)
    end
    config
  end

  # :reek:TooManyStatements
  def setup_ledger(config:)
    custom_renderer = Aardi::CustomRenderer.new
    markup_opts = config[:markup_options] || {}
    markdown_renderer = Redcarpet::Markdown.new(custom_renderer, markup_opts)
    ledger = Aardi::Ledger.new
    ledger[:custom_renderer] = custom_renderer
    ledger[:markdown_renderer] = markdown_renderer
    ledger[:content_hashes] = Aardi::ContentHashes.new('/nonexistent_test_hashes')
    ledger[:html_files] = Set.new

    html = File.read(File.join(SAMPLES_DIR, 'minimal_template.html'))
    Tempfile.create(['template', '.html']) do |file|
      file.write(html)
      file.flush
      ledger[:template] = Aardi::Template.new(file.path, ledger:)
    end

    ledger
  end
end

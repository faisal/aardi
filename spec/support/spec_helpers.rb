# frozen_string_literal: true

module SpecHelpers
  SAMPLES_DIR = File.expand_path('../samples', __dir__)

  def page_by_sample_path(filename)
    Aardi::Page.new sample_path(filename)
  end

  def sample_path(filename)
    File.join(SAMPLES_DIR, filename)
  end

  # :reek:TooManyStatements
  # :reek:FeatureEnvy
  def setup_config(overrides = {})
    Aardi.reset!
    base = YAML.safe_load_file(File.join(SAMPLES_DIR, 'minimal_config.yml'))
    defaults = { 'template_path' => sample_path('minimal_template.html') }
    config_data = base.merge(defaults).merge(overrides.transform_keys(&:to_s))
    Tempfile.create(['config', '.yml']) do |file|
      file.write(config_data.to_yaml)
      file.flush
      Aardi.config.load(file.path)
    end
  end

  def setup_ledger
    ledger = Aardi.ledger
    ledger[:content_hashes] = Aardi::ContentHashes.new('/nonexistent_test_hashes')
    ledger[:html_files] = Set.new
    ledger[:renderer] = Aardi::Renderer.new
  end
end

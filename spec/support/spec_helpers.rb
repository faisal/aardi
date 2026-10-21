# frozen_string_literal: true

module SpecHelpers
  SAMPLES_DIR = File.expand_path('../samples', __dir__)
  OMIT = Object.new.freeze

  def deprecation_count(message, &) = capture_io(&).last.scan(message).size

  def deprecation_message(shim, replacement)
    "#{shim} is deprecated and will be removed in a future release; use #{replacement} instead."
  end

  def deprecation_warning_at(file, line, message)
    /\A#{Regexp.escape(file)}:#{line}: warning: #{Regexp.escape(message)}\n\z/
  end

  def make_renderer(html_files: Set.new, content_hashes: stub_content_hashes, sitemap: stub_sitemap)
    Aardi.renderer = Aardi::Renderer.new(html_files:, content_hashes:, sitemap:)
  end

  def page_by_sample_path(filename)
    Aardi::Page.new sample_path(filename)
  end

  def sample_path(filename)
    File.join(SAMPLES_DIR, filename)
  end

  def setup_config(overrides = {})
    Aardi.reset!
    base = YAML.safe_load_file(File.join(SAMPLES_DIR, 'minimal_config.yml'))
    defaults = { 'template_path' => sample_path('minimal_template.html') }
    config_data = base.merge(defaults).merge(overrides.transform_keys(&:to_s))
    config_data.reject! { |_, value| value.equal?(OMIT) }
    Tempfile.create(['config', '.yml']) do |file|
      file.write(config_data.to_yaml)
      file.flush
      Aardi::Config.load(file.path)
    end
  end

  private

  def stub_content_hashes
    Aardi::ContentHashes.new('/nonexistent_test_hashes')
  end

  def stub_sitemap
    Object.new.tap do |stub|
      stub.define_singleton_method(:record_mtime) { |*| nil }
      stub.define_singleton_method(:update_mtime) { |*| nil }
    end
  end
end

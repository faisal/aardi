# frozen_string_literal: true

module Aardi
  class ContentHashes
    def initialize(path)
      @path = path
      read_hashes
    end

    def [](path)
      @hashes[path]
    end

    def []=(path, hash)
      @hashes[path] = hash
    end

    def write
      return if new_hashes == @original_hashes

      File.write(@path, @new_hashes)
      puts "Wrote: #{@path}\n"
    end

    private

    def new_hashes
      @new_hashes ||= @hashes.sort.map { |path, hash| "#{path}: #{hash}\n" }.join
    end

    def read_hashes
      @original_hashes = File.exist?(@path) ? File.read(@path) : ''
      @hashes = @original_hashes.scan(/^(.+): (\d+)$/).to_h { |path, hash| [path, hash.to_i] }
    end
  end
end

# frozen_string_literal: true

module CacheHelpers
  # Temporarily switch Rails.cache to an in-memory store for the duration of the block.
  # Useful for testing cache behaviour in specs where the default test store is NullStore.
  def with_memory_cache
    original = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    yield
  ensure
    Rails.cache = original
  end
end

RSpec.configure do |config|
  config.include CacheHelpers
end

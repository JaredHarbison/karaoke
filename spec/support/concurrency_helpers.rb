# frozen_string_literal: true

module ConcurrencyHelpers
  def run_concurrently(items, &block)
    ready = Queue.new
    start = Queue.new

    threads = items.map { |item| concurrent_thread(item, ready, start, &block) }

    items.length.times { ready.pop }
    items.length.times { start << true }
    threads.map(&:value)
  end

  private

  def concurrent_thread(item, ready, start, &block)
    Thread.new do
      ActiveRecord::Base.connection_pool.with_connection do
        ready << true
        start.pop
        block.call(item)
      end
    end
  end
end

RSpec.configure do |config|
  config.include ConcurrencyHelpers, type: :service
end

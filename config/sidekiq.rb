# frozen_string_literal: true

require 'sidekiq'

redis_conn = proc {
  Redis.new(
    url: 'redis://localhost:6379/14',
    driver: :hiredis,
    network_timeout: 5,
    failover_reconnect_timeout: 20,
    reconnect_attempts: 1
  )
}

Sidekiq.configure_client do |config|
  config.redis = ConnectionPool.new(size: 5, &redis_conn)
end

Sidekiq.configure_server do |config|
  config.redis = ConnectionPool.new(size: 25, &redis_conn)
end

Redis.current = Redis.new(
  url: ENV.fetch('ANYCABLE_REDIS_URL') { 'redis://localhost:6379/15' },
  driver: :hiredis, network_timeout: 5,
  failover_reconnect_timeout: 20, reconnect_attempts: 1
)

# frozen_string_literal: true

require 'sidekiq'

redis_conn = proc {
  Redis.new(
    url: 'redis://mymaster/14',
    sentinels: [{ host: 'localhost', port: 26379 }],
    role: :master,
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
  url: 'redis://localhost:6380/15',
  driver: :hiredis, network_timeout: 5,
  failover_reconnect_timeout: 20, reconnect_attempts: 1
)

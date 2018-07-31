# frozen_string_literal: true

require 'message_bus'

MessageBus.configure(
  backend: :redis,
  url: 'redis://mymaster/15',
  sentinels: [{ host: 'localhost', port: 26379 }],
  role: :master,
  driver: :hiredis,
  network_timeout: 5,
  failover_reconnect_timeout: 20,
  reconnect_attempts: 1
)

# define a site_id lookup method
MessageBus.configure(is_admin_lookup: proc do
  true
end)
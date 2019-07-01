# frozen_string_literal: true

require './config/sidekiq'
require './app_cable'

class MessageBusWorker
  include Sidekiq::Worker
  sidekiq_options retry: false # job will be discarded immediately if failed

  def perform(channel, message)
    Redis.current.publish(
      '__anycable__', MultiJson.dump(
        stream: channel,
        command: 'message',
        data: MultiJson.dump(message)
      )
    )
  end
end

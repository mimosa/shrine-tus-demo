# frozen_string_literal: true

require './config/sidekiq'

class MessageBusWorker
  include Sidekiq::Worker
  sidekiq_options retry: false # job will be discarded immediately if failed

  def perform(channel, data, opts = {})
    MessageBus.publish channel, data, opts
  end
end

# frozen_string_literal: true

require './config/sidekiq'

class ShrineWorker
  include Sidekiq::Worker
  sidekiq_options retry: 1

  def perform(action, data)
    Shrine::Attacher.send(action, data) if Shrine::Attacher.respond_to?(action)
  end
end

# frozen_string_literal: true

require './config/sucker_punch'

class ShrineJob
  include SuckerPunch::Job

  def perform(action, data)
    Shrine::Attacher.send(action, data) if Shrine::Attacher.respond_to?(action)
  end
end

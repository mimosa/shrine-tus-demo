# frozen_string_literal: true

require './config/sucker_punch'

class MessageBusJob
  include SuckerPunch::Job

  def perform(channel, data, opts = {})
    MessageBus.publish channel, data, opts
  end
end

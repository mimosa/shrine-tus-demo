# frozen_string_literal: true

require './config/lite_cable'

module AppCable
  class Connection < LiteCable::Connection::Base # :nodoc:
    identified_by :current_user

    def connect
      @current_user = {
        username: 'test',
        user_id: '1111'
      }
    end

    def disconnect
      puts "#{@current_user} disconnected"
      puts '_' * 88
    end
  end

  class Channel < LiteCable::Channel::Base # :nodoc:
    identifier :notifications

    def subscribed
      stream_from 'notifications'
    end

    def speak(data)
      LiteCable.broadcast 'notifications', user: current_user, message: data['message']
    end
  end
end

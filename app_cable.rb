# frozen_string_literal: true

require 'litecable'

module AppCable
  class Connection < LiteCable::Connection::Base # :nodoc:
  end

  class Channel < LiteCable::Channel::Base # :nodoc:
  end
end

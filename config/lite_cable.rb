# frozen_string_literal: true

require File.expand_path('../app_cable', __dir__)

LiteCable.config.log_level = Logger::DEBUG

require 'anycable'

LiteCable.anycable! # Turn AnyCable compatibility mode

Anycable.connection_factory = AppCable::Connection

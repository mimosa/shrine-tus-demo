# frozen_string_literal: true

require 'anycable'
require 'litecable'

LiteCable.config.log_level = Logger::DEBUG
LiteCable.anycable! # Turn AnyCable compatibility mode

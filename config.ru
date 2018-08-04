# frozen_string_literal: true

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('./Gemfile', __dir__)
require 'bundler/setup' # Set up gems listed in the Gemfile.
require 'active_support'
require 'active_support/core_ext'
require './app'
require './app_cable'

use Rack::MethodOverride

require './config/sidekiq'
require 'sidekiq/web'

run Rack::URLMap.new(
  '/sidekiq' => Sidekiq::Web,
  '/' => App
)

# frozen_string_literal: true

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('./Gemfile', __dir__)
require 'bundler/setup' # Set up gems listed in the Gemfile.
require 'active_support'
require 'active_support/core_ext'
require './app'

use Rack::MethodOverride

require './config/sidekiq'
require 'sidekiq/web'

cable = Rack::Builder.new do
  map "/" do
    use LiteCable::Server::Middleware, connection_class: AppCable::Connection

    run(proc { |_| [200, {"Content-Type" => "text/plain"}, ["OK"]] })
  end
end

run Rack::URLMap.new(
  '/sidekiq' => Sidekiq::Web,
  '/cable' => cable,
  '/' => App
)

require './app'

if ENV['RACK_ENV'] == 'production'
  require 'rack/ssl'
  use Rack::SSL
end

run Sinatra::Application

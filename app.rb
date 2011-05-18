require 'bundler/setup'
require 'sinatra'
require 'erubis'
require 'oa-oauth'

if ENV['RACK_ENV'] == 'production'
  require 'rack/ssl'
  use Rack::SSL
end

fail 'Missing ENV: GITHUB_ID & GITHUB_SECRET' unless ENV['GITHUB_ID'] && ENV['GITHUB_SECRET']
use OmniAuth::Strategies::GitHub, ENV['GITHUB_ID'], ENV['GITHUB_SECRET']

set :erubis, :escape_html => true
set :sessions, true

get '/' do
  redirect to('/auth/github')
end

get '/auth/github/callback' do
  raise request.env
  auth_hash = request.env['omniauth.auth']
  raise auth_hash.inspect
  # begin
  #   token = oauth2.web_server.get_access_token(params[:code], :redirect_uri => redirect_uri)
  #   @repos = token.get('/api/v2/json/organizations/repositories?owned=1')['repositories']
  # rescue OAuth2::AccessDenied
  #   redirect to('/auth/github')
  # end
  #   @repos = @repos.select { |repo| repo['private'] }
  #   @repos = @repos.sort_by { |repo| [-repo['open_issues'], repo['name']] }
  #   @repos.each do |repo|
  #     if repo['open_issues'] > 0
  #       name = repo['url'].gsub('https://github.com/', '')
  #       issues = token.get("/api/v2/json/issues/list/#{name}/open")['issues']
  #       repo['issues'] = issues
  #     end
  #   end
  # erubis :index
end

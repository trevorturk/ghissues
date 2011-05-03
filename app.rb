require 'sinatra'
require 'oauth2'

get '/' do
  redirect to('/auth/github')
end

get '/auth/github' do
  redirect oauth2.web_server.authorize_url(:redirect_uri => redirect_uri, :scope => 'user,repo')
end

get '/auth/github/callback' do
  begin
    token = oauth2.web_server.get_access_token(params[:code], :redirect_uri => redirect_uri)
    repos = token.get('/api/v2/json/organizations/repositories?owned=1')['repositories']
    repos = repos.select { |repo| repo['private'] }
    repos = repos.sort_by { |repo| [-repo['open_issues'], repo['name']] }
    html = '<ul>'
    repos.each do |repo|
      html << "<li><a href='#{repo['url']}/issues'>#{repo['name']}</a> (#{repo['open_issues']})</li>"
      if repo['open_issues'] > 0
        name = repo['url'].gsub('https://github.com/', '')
        issues = token.get("/api/v2/json/issues/list/#{name}/open")['issues']
        html << '<ul>'
        issues.each do |issue|
          html << "<li><a href='#{issue['html_url']}'>#{issue['title']}</a></li>"
        end
        html << '</ul>'
      end
    end
    html << '</ul>'
  rescue OAuth2::AccessDenied
    redirect to('/auth/github')
  end
end

def oauth2
  OAuth2::Client.new(ENV['GITHUB_ID'], ENV['GITHUB_SECRET'],
    :site => 'https://github.com',
    :authorize_path => '/login/oauth/authorize',
    :access_token_path => '/login/oauth/access_token',
    :parse_json => true)
end

def redirect_uri(path = '/auth/github/callback', query = nil)
  uri = URI.parse(request.url)
  uri.path  = path
  uri.query = query
  uri.scheme = 'https' if RACK_ENV == 'production'
  uri.to_s
end

require 'sinatra/base'
require 'json'

class FakeGitHub < Sinatra::Base
  post '/login/oauth/access_token' do
    if rate_limit_expired
      json_response 200,  access_token: 'rate_limit_expired'
    elsif access_fail
      json_response 500, access_token: nil
    else
      json_response 200,  access_token: 'access'
    end
  end

  get '/user' do
    json_response 200, 'user.json'
  end

  get '/user/repos' do
    json_response 200, 'repos.json'
  end

  get '/user/orgs' do
    json_response 200, 'organization.json'
  end

  get '/orgs/:org/repos' do
    json_response 200, 'org_repos.json'
  end

  get '/rate_limit' do
    if rate_limit_expired
      headers = {}
      headers['X-RateLimit-Limit'] = '5000'
      headers['X-RateLimit-Remaining'] = '0'
      headers['X-RateLimit-Reset'] = '1500000000'

      json_response 200, 'rate_limit_exp.json', headers
    else
      headers = {}
      headers['X-RateLimit-Limit'] = '5000'
      headers['X-RateLimit-Remaining'] = '4999'
      headers['X-RateLimit-Reset'] = '1372700873'

      json_response 200, 'rate_limit.json', headers
    end
  end

  post '/repos/:username/:repository/issues' do
    body = JSON.parse(request.body.string)
    overrides = body['title'] == 'Custom Title' ? { 'Git Reports Issue' => 'Custom Title' } : {}
    json_response 201, 'issue.json', nil, overrides
  end

  private

  def access_fail
    params[:code] == 'access_fail'
  end

  def rate_limit_expired
    request.env['HTTP_AUTHORIZATION'] == 'token rate_limit_expired' || params[:code] == 'rate_limit_expired'
  end

  def json_response(response_code, content, headers = nil, overrides = {})
    content_type :json
    status response_code

    if headers
      headers.each do |k, v|
        response[k] = v
      end
    end

    if content.is_a? Hash
      content.to_json
    else
      response_json = File.open(File.expand_path('../../', __FILE__) + '/fixtures/' + content, 'rb').read
      # Replace any overrides in the JSON.
      overrides.each { |k, v| response_json.gsub!(k, v) }
      response_json
    end
  end
end

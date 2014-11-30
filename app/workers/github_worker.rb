class GithubWorker
  include Sidekiq::Worker

  def perform(access_token, *args)
    GithubService.load_repositories(access_token)
  end
end
class GithubWorker
  include Sidekiq::Worker

  def perform(method, *args)
    GithubService.send(method, *args)
  end
end

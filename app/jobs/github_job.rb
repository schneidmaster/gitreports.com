class GithubJob < ActiveJob::Base
  queue_as :default

  def perform(method, *args)
    GithubService.send(method, *args)
  end
end

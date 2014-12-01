class EmailWorker
  include Sidekiq::Worker

  def perform(klass, method, *args)
    klass.constantize.send(method, *args).deliver
  end
end

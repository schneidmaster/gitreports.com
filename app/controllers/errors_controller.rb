class ErrorsController < ApplicationController
  def error_404
    render(status: 404)
  end

  def error_422
    render(status: 422)
  end

  def error_500
    render(status: 500)
  end
end

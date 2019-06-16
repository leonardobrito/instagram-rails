class ApplicationController < ActionController::API
  def index
    render json: { status: 'It\'s work!'}
  end
end

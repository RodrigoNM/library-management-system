module AuthenticateUser
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  private

  def authenticate_user!
    unless current_user
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end

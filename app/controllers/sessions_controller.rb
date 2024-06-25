class SessionsController < Devise::SessionsController
  respond_to :json
  private

  def respond_with(resource, _opts = {})
    render json: { message: "Logged in successfully.", token: current_token }, status: :ok
  end

  def respond_to_on_destroy
    if current_user
      render json: { message: "Logged out successfully." }, status: :ok
    else
      render json: { message: "User not found." }, status: :unauthorized
    end
  end

  def current_token
    request.env["warden-jwt_auth.token"]
  end
end

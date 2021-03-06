class SessionsController < Devise::SessionsController

  # do not require Auth if you create a session (since you cannot be logged in before logging in)
  prepend_before_filter :require_no_authentication, only: [:create]

  def create
    user = User.find_for_database_authentication(email: params[:email])

    if user && user.valid_password?(params[:password])
      sign_in user
        render json: {
          id: user.id,
          email: user.email,
          authentication_token: user.authentication_token
        }, status: 201
    else
      render json: {
        errors: ["Invalid email or password"]
      }, status: 422
    end
  end

  def show
    render json: current_user
  end
  
  def destroy
    current_user.authentication_token = nil
    current_user.save
    render json: {}, status: 201
  end

  private
  def current_user
    User.find_by authentication_token: params[:authentication_token]
  end

end

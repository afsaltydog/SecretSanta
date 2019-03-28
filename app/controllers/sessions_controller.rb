class SessionsController < ApplicationController
  def new
    # render login page
  end
  def create
      # Log User In
      # if authenticate true
          # save user id to session
          # redirect to users profile page
      # if authenticate false
          # add an error message -> flash[:errors] = ["Invalid"]
          # redirect to login page
  end
  def destroy
      # Log User out
      # set session[:user_id] to null
      # redirect to login page
  end
  def current_user
    User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user
end

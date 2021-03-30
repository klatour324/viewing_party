class SessionController < ApplicationController
  def new; end

  def create
    user = User.find_by(email: params[:email].downcase)
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      flash[:success] = "Welcome, #{user.email}"
      redirect_to dashboard_path
    else
      flash[:error] = 'Wrong email/password'
      render :new
    end
  end

  def destroy
    session.delete :user_id
    flash[:notice] = 'You have been successfully logged out'
    redirect_to root_path
  end
end

class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def show
    @user = current_user
    @user_hosting_parties = @user.parties
    # require "pry"; binding.pry
    @invited = @user.invites

    invited = current_user.invites
    hosting = current_user.parties
    @parties = {
      invited_to: invited,
      hosted: hosting
    }
  end

  def create
    user = user_params
    user[:email] = user[:email]
    new_user = User.new(user)
    if new_user.save
      flash[:success] = "Welcome, #{new_user.email}!"
      session[:user_id] = new_user.id
      redirect_to dashboard_path
    else
      flash[:error] = new_user.errors.full_messages.uniq.to_sentence

      redirect_to new_user_path
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end

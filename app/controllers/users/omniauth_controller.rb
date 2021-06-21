class Users::OmniauthController < ApplicationController
  def google_oauth2
    @user = User.create_from_google_data(request.env['omniauth.auth'])
    @user.api_key = Digest::MD5.hexdigest @user.email
    @user.save
    if @user.persisted?
      sign_in_and_redirect @user
      session[:user_id] = @user.id
      # set_flash_message(:notice, :success, kind: 'Google') if is_navigational_format?
    else
      flash[:error] = 'There was a problem signing you in through Google. Please register or try signing in later.'
      redirect_to new_user_registration_url
    end 
  end
  
  def failure
    flash[:error] = 'There was a problem signing you in. Please register or try signing in later.' 
    redirect_to new_user_registration_url
  end
  
  def logout
    session[:user_id] = nil
  end
end

# A controller to handle user sessions
class Api::UsersController < ApplicationController

  before_filter :logger

  # login action
  # http://localhost:3001/api/login?email=isbaysoft@gmail.com&password=qwe123
  #  ID = 2
  def login
    user = User.find_by_email(params[:email])
    if user && user.valid_password?(params[:password])
      user.reset_authentication_token!
      user_sign_in user, params[:imei]
      
      render_with_log :json => {:token => user.authentication_token, :devices => user.devices.flatten.uniq.map(&:mac)}
    else
      render_with_log :json => {:status => 403, :message => 'email and/or password is incorrect'}
    end
  end

  # http://localhost:3001/api/sign_up?email=isbaysoft@gmail.com&password=qwe123
  def sign_up
# “device” : ”<device_id>”,
    user = User.new :email => params[:email], 
      :password => params[:password],
      :name => params[:email],
      :login => params[:email]
    if user.save
      user.reset_authentication_token!
      render_with_log :json => {:token => user.authentication_token, :user_id => user.id}
    else
      render_with_log :json => {:status => 403, :message => user.errors.full_messages.join(', ')}
    end
  end

protected

  def render_with_log options = {}
    @logger.info "LOGIN_#{DateTime.now.strftime('%Y%m%d %H:%M:%S')}: response #{options}"
    render options
  end

  def user_sign_in user, imei
    sign_in(:user, user)
    Phone.find_or_create_by_imei_and_user_id imei, user.id if imei
  end

  def logger
    @logger.info "LOGIN_#{DateTime.now.strftime('%Y%m%d %H:%M:%S')}: params #{params}"    
  end

end

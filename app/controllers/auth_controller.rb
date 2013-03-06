class AuthController < ApplicationController
  include PicasaAuth

  def login
    redirect_to oauth_client.auth_code.authorize_url(
      :scope => "http://picasaweb.google.com/data/",
      :access_type => "offline",
      :redirect_uri => "http://localhost:3005/callback",
      :approval_prompt => 'force')
  end

  def callback
    access_token_obj = oauth_client.auth_code.get_token(params[:code],
      :redirect_uri =>  "http://localhost:3005/callback",
      :token_method => :post)
    session[:token] = {
      :access_token => access_token_obj.token,
      :refresh_token => access_token_obj.refresh_token
    }
    puts session[:token]
    redirect_to :controller => :albums, :action => :index
  end
end
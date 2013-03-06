class AlbumsController < ApplicationController
  # rescue_from Exception, :with => :error_render_method
  before_filter :ensure_token

  def index
    @albums = Picasa.albums(session[:token])
  end

  def show
    @album = Picasa.photos(session[:token], params[:id])
  end

  def comments
    @photo = Picasa.comments(session[:token], params[:album_id], params[:photo_id])
    render :layout => false
  end

  def comment
    @comment = Picasa.add_comment(session[:token], params[:comment][:album_id], params[:comment][:photo_id], params[:comment][:text])
  end

  def ensure_token
    redirect_to :action => :login, :controller => :auth unless session[:token]
  end
end

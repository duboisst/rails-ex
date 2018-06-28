class SessionsController < ApplicationController
  skip_before_action :authenticate

# GET /sessions/new
def new
end

# POST /sessions
# POST /sessions.xml
  def create
    u = User.authenticate(params[:login][:name], params[:login][:password])
    session[:user] = u
    redirect_to :controller => :news
  rescue RuntimeError => exc
    flash[:notice] = exc.message
    redirect_to :controller => :sessions, :action => :new
  end

# DELETE /login
# DELETE /login.html
  def destroy
    session[:user] = @current_user = nil
    redirect_to :controller => :sessions, :action => :new
  end

  def not_permitted

  end
end

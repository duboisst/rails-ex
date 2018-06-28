# encoding: utf-8
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate, :authorize, :load_sites, :flash_message
  helper :all # include all helpers, all the time

protected

  # méthode before_action appelée avant toute autre méthode de tout controller.
  # Si la variable de session :user n'existe pas, on redirige sur la page de login
  def authenticate
    if session[:user]
      @current_user = session[:user]
    else
      #Si un certificat client est présenté, on vérifie que le CN est connu
      if request.env["HTTP_SSL_CLIENT_CN"] and request.env["HTTP_SSL_CLIENT_CN"] != '(null)'
        session[:user] = @current_user = User.find_by_name(request.env["HTTP_SSL_CLIENT_CN"])
        flash[:notice] = "L'utilisateur #{request.env["HTTP_SSL_CLIENT_CN"]} n'est pas autorisé à accéder à cette application" if @current_user.nil?
        login_required if @current_user.nil?
      else # Si pas de certificat, on demande le login/password
        case request.format
        when 'application/atom+xml', 'application/xml'
          begin            
            session[:user] = @current_user = authenticate_with_http_basic { |u, p| 
              User.authenticate(u, p)
            }
            request_http_basic_authentication if @current_user.nil?
          rescue
            request_http_basic_authentication
          end
        else       
          login_required
        end
      end
    end
  end

  # méthode before_filter appelée avant toute autre méthode de tout controller.
  # on surchargera cette méthode dans les autre controlleurs si on a besoin de restreindre l'accès
  def authorize

  end

  def admin_role_required
    unless @current_user.is_admin
      flash[:notice] = MSG_NOT_AUTHORIZED
      login_required
    end
  end

  def load_sites
    @sites = []
    params = open('config/index.yml') {|f| YAML.load(f) }
    params.each {|p| @sites << p['site']}
    @sites.sort!
  end

  def maintenance
    m = Maintenance.first
    unless m.nil?
      redirect_to maintenance_url if m.is_in_maintenance?
    end
  end

  def flash_message
    m = Maintenance.first
    unless m.nil?
	  @flash_message = m.flash_message
	  @flash_message_color = m.flash_message_color
	else
	  @flash_message = ""
	  @flash_message_color = ""
    end  
  end
  
private
  
  def login_required
    #request_http_basic_authentication
    redirect_to :controller => "/sessions", :action => :new
  end
end

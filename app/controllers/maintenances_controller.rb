class MaintenancesController < ApplicationController

  def maintenance_params
    params.require(:maintenance).permit(:is_in_maintenance, :reason, :created_at, :updated_at, :flash_message, :flash_message_color)
  end
  
  # GET /maintenance
  # GET /maintenance.xml
  def show
    if params[:preview] == 'true'
      @maintenance = Maintenance.new(params[:maintenance])
      @preview = true
    else
      @maintenance = Maintenance.find(:first)
    end
    if !@maintenance.nil? and @maintenance.is_in_maintenance?
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @maintenance }
      end
    else
      redirect_to news_index_url
    end
  end

private

  def authenticate
    @current_user = session[:user]
  end

end

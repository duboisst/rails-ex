class Admin::MaintenancesController < ApplicationController

  # GET /maintenance/edit
  def edit
    @maintenance = Maintenance.find(:first)
    if @maintenance.nil?
      @maintenance = Maintenance.create(:is_in_maintenance => :false)
    end
  end

  # PUT /maintenance
  # PUT /maintenance.xml
  def update
    @maintenance = Maintenance.find(:first)
    if @maintenance.nil?
        @maintenance = Maintenance.create(:is_in_maintenance => :false)
    end

    params[:maintenance][:is_in_maintenance] = params[:maintenance][:is_in_maintenance] == 'true'?true:false
    respond_to do |format|
      if @maintenance.update_attributes(params[:maintenance])
        flash[:notice] = 'CABLe est de nouveau accessible.' unless @maintenance.is_in_maintenance?
        format.html { redirect_to :controller => "/news" }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @maintenance.errors, :status => :unprocessable_entity }
      end
    end
  end
 
  def authorize
    admin_role_required
  end
end

# encoding: utf-8
class Admin::ChannelsController < ApplicationController

  # GET /channels
  # GET /channels.xml
  def index
    @channels = Channel.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @channels }
    end
  end

  # GET /channels/1
  # GET /channels/1.xml
  def show
    @channel = Channel.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @channel }
    end
  end

  # GET /channels/new
  # GET /channels/new.xml
  def new
    @channel = Channel.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @channel }
    end
  end

  # GET /channels/1/edit
  def edit
    @channel = Channel.find(params[:id])
  end

  # POST /channels
  # POST /channels.xml
  def create
    @channel = Channel.new(params[:channel])
    respond_to do |format|
      if @channel.save
        flash[:notice] = 'Canal créé.'
        format.html { redirect_to :action=>:show, :id=>@channel.id }
        format.xml  { render :xml => @channel, :status => :created, :location => @channel }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @channel.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /channels/1
  # PUT /channels/1.xml
  def update
    @channel = Channel.find(params[:id])

    respond_to do |format|
      if @channel.update_attributes(params[:channel])
        flash[:notice] = 'Canal modifié.'
        format.html { redirect_to :action=>:show, :id=>@channel.id }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @channel.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /channels/1
  # DELETE /channels/1.xml
  def destroy
    @channel = Channel.find(params[:id])
    @channel.destroy

    respond_to do |format|
      format.html { redirect_to admin_channels_url }
      format.xml  { head :ok }
    end
  end

  # on surcharge la méthode authorize de la classe ApplicationController pour
  # n'autoriser que les administrateurs à exécuter les méthodes de ce controller.
  # +admin_role_required+[link:../app/classes/ApplicationController.html#M000030] est définie dans la classe ApplicationController
  def authorize
    admin_role_required
  end
end

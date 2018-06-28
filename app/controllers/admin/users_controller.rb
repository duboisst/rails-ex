# encoding: utf-8
require 'will_paginate'

class Admin::UsersController < ApplicationController

  # GET /users
  # GET /users.xml
  def index
    conditions = [ "lower(name) like ? OR lower(login) like ?", "#{params[:filter]}%".downcase, "#{params[:filter]}%".downcase ] unless params[:filter].blank? or params[:filter].nil?
    @users = User.paginate(:conditions => conditions, :page => params[:page], :order => 'name ASC', :per_page => 50)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new(:login=>params[:login], :name=>params[:name], :dn=>params[:dn])

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        flash[:notice] = 'Utilisateur créé.'
        format.html { redirect_to :action=>:show, :id=>@user.id }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'Utilisateur modifié.'
        format.html { redirect_to :action=>:show, :id=>@user.id }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    respond_to do |format|
      if @current_user.login != @user.login then
        @user.destroy
        format.html { redirect_to admin_users_url }
        format.xml  { head :ok }
      else
        flash[:notice] = 'Impossible de supprimer votre propre utilisateur.'
        format.html { redirect_to :action=>:show, :id=>@user.id }
        format.xml  {  render :xml => @user.errors, :status => :unprocessable_entity }      
      end
    end
  end

  # on surcharge la méthode authorize de la classe ApplicationController pour
  # n'authoriser que les administrateurs à exécuter les méthodes de ce controller.
  # +admin_role_required+[link:../app/classes/ApplicationController.html#M000030] est définie dans la classe ApplicationController
  def authorize
    admin_role_required
  end
  
end

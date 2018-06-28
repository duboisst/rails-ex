# encoding: utf-8
require 'will_paginate'

class BonsController < ApplicationController
  prepend_before_filter :maintenance
# GET /bons
# GET /bons.xml
  def index
    # on initialise le tableau de retour pour avoir un tableau vide en cas d'exception
    @search = []

    start_time = Time.now
    
    if !params[:date1].to_s.strip.empty?
      begin
        params[:date1] = DateTime.strptime(params[:date1], "%d/%m/%Y")
      rescue
        params[:date1] = DateTime.parse(params[:date1])
      end
    else
      params[:date1] = nil
    end
    if !params[:date2].to_s.strip.empty?
      begin
        params[:date2] = DateTime.strptime(params[:date2], "%d/%m/%Y")
      rescue
        params[:date2] = DateTime.parse(params[:date2])
      end
    else
      params[:date2] = nil
    end

    Log.create(:user_id => @current_user.id, :action => "search", :params => params) unless params.has_key?(:per_page)

    respond_to do |format|
      format.html {
        params[:per_page] = 30
        begin
          # on effectue la recherce en restreignant aux canaux autorisés pour le user en cours
          if @current_user.all_channels
            bons, @total_entries = Bon.find_with_ferret(params)
          else
            bons, @total_entries = Bon.find_with_ferret(params, :channels => @current_user.profile.channels)
          end
          @search = WillPaginate::Collection.create(params[:page] || 1, params[:per_page]) do |pager|
            # inject the result array into the paginated collection:
            pager.replace(bons)
            pager.total_entries = @total_entries
          end
        rescue Exception => exc
          flash[:notice] = "Impossible d'exécuter cette recherche<br />Raison:<i>  #{exc.message}</i>"
        end
        @elapsed_time = Time.now - start_time
      }

      format.xml {
        params[:per_page] = params[:limit] || 100
        params[:per_page] = 100 if params[:per_page].to_i > 100
        @offset = params[:offset] || 1
        begin
          # on effectue la recherche en restreignant aux canaux autorisés pour le user en cours
          if @current_user.all_channels
            bons, @total_entries = Bon.find_with_ferret(params)
          else
            bons, @total_entries = Bon.find_with_ferret(params, :channels => @current_user.profile.channels)
          end
          @search = bons
        rescue Exception => exc
          flash[:notice] = "Impossible d'exécuter cette recherche<br />Raison:<i>  #{exc.message}</i>"
        end
        @elapsed_time = Time.now - start_time
     }
    end
    
  end
  
  # GET /bons/1
  # GET /bons/1.xml
  # Envoie le fichier vers le browser par la méthode *send_file*
  def show
    bon = Bon.from_hash(params[:bon])
    if bon.nil? or bon.invalid?
      flash[:notice]  = "Ce bon de livraison n'existe pas."
      redirect_to :back rescue redirect_to :controller => :news
    else
      if @current_user.all_channels or @current_user.channels.include?(bon.canal)
        Log.create(:user_id => @current_user.id, :action => "show", :params => {:bon => params[:bon]})
        send_file ENV['CABLE_PDF_PATH'] + bon.file, :type => 'application/pdf', :disposition => 'inline'
      else
        flash[:notice]  = "Vous n'êtes pas autorisé à consulter ce bon."
        redirect_to :back rescue redirect_to :controller => :news
      end
    end
  end
end

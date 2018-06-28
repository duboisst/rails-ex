require 'will_paginate'

class Admin::LdapUsersController < ApplicationController

  # GET /admin/ldap_users/new
  def new

  end
  
  # GET /admin/ldap_users
  # GET /admin/ldap_users.xml
  def index
    if !params[:ldap_search].nil?
      begin
        params[:per_page] = 30
        users = User.ldap_search(params[:ldap_search])
        @users = WillPaginate::Collection.create(params[:page] || 1, params[:per_page]) do |pager|
            pager.replace(users)
            pager.total_entries = @total_entries
          end
        #@users = users.paginate :page => params[:page] || 1, :per_page => 10
      rescue Net::LDAP::LdapError => exc
        flash[:notice] = "LDAP Error: #{exc.message}"
      end
    end
    respond_to do |format|
      format.html
      format.xml  { head :ok }
    end
  end

  # on surcharge la méthode authorize de la classe ApplicationController pour
  # n'authoriser que les administrateurs à exécuter les méthodes de ce controller.
  # +admin_role_required+[link:../app/classes/ApplicationController.html#M000030] est définie dans la classe ApplicationController
  def authorize
    admin_role_required
  end
 
end

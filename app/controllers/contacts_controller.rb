class ContactsController < ApplicationController

  # GET /contacts
  # GET /contacts.xml
  def index
    @contacts = Contact.find(:all, :order => "name ASC")
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @contacts }
    end
  end

private

  def authenticate
    @current_user = session[:user]
  end
end

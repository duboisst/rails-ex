class NewsController < ApplicationController
  prepend_before_action :maintenance
  
  def index

  end
end

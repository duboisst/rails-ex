class LogsController < ApplicationController
  def show
    @logs = Log.find_all_by_user_id(@current_user.id)
  end
end

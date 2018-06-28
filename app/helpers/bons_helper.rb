module BonsHelper
  def canal_column_header
    if @current_user.multiple_channels    
      "<td>Canal</td>"
    end
  end

  def canal_column_body(bon)
    if @current_user.multiple_channels then
      "<td>#{bon.canal.name}</td>"
    end
  end
  
  def columns_number
    if @current_user.multiple_channels then
      6
    else
      5
    end
  end

  def navigation(params)
    pfirst = Hash.new.merge!(params)
    pfirst["page"] = 1

    pnext = Hash.new.merge!(params)
    pnext["page"] = params[:page].to_i + 1

    pprevious = Hash.new.merge!(params)
    pprevious["page"] = params[:page].to_i - 1

    plast = Hash.new.merge!(params)
    plast["page"] = @total_entries / params[:per_page].to_i + 1

    return pprevious, pfirst, pnext, plast
  end

end


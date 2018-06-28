# encoding: utf-8
module LogsHelper
  def display_log(log)
    response = ""
    case log.action
    when "show" then
      bon = Bon.new(log.params[:bon])
      response << "<table class=\"log\"><tr>\n"
      response << "<td>" << format_hour(log.created_at.getlocal.strftime('%H:%M')) << "</td>\n"
      response << "<td>" << link_to(image_tag('loupe.gif'), bon_path(:bon =>log.params[:bon]), :target => "_blank") << "</td>\n"
      response << "<td>" << " <i>site</i>: #{h(bon.site)} - <i>canal</i>: #{h(bon.canal.name)} - <i>op</i>: #{h(bon.op)} - <i>commande</i>: #{h(bon.commande)}" << "</td>\n"
      response << "</tr></table>\n"
    when "search" then
      canal = Channel.find_by_code(log.params[:canal]).name rescue log.params[:canal] unless log.params[:canal].blank?
      response << "<table class=\"log\"><tr>\n"
      response << "<td>" << format_hour(log.created_at.getlocal.strftime('%H:%M')) << "</td>\n"
      response << "<td>" << link_to(image_tag('search.gif'), bons_path(log.params))<< "</td>\n"
      response << "<td>"
      response << "<i>canal</i>: #{h(canal)} " unless canal.nil?
      params = []
      log.params.reject {|key, value| value.blank? or key=="commit" or key=="action" or key=="controller" or key=="canal" or key =="utf8"}.each_pair{|key, value|params << "<i>#{format_key(key)}</i>: #{format_value(key, value)}"}
      response << " - " if !canal.nil? and !params.empty?
      response << params.join(" - ")
      response << "</td>\n</tr></table>\n"
    end
    return response
  end

  def french_date(d)
    jour = {"Monday" => "Lundi", "Tuesday" => "Mardi", "Wednesday" => "Mercredi", "Thursday" => "Jeudi", "Friday" => "Vendredi", "Saturday" => "Samedi", "Sunday" => "Dimanche"}
    mois = {"January" => "Janvier", "February" => "Février", "March" => "Mars", "April" => "Avril", "May" => "Mai", "June" => "Juin", "July" => "Juillet", "August" => "Août", "September" => "Septembre", "October" => "Octobre", "November" => "Novembre", "December" => "Décembre"}
    "#{jour[d.strftime("%A")]} #{d.strftime("%d")} #{mois[d.strftime("%B")]}"
  end

  def format_hour(hour)
    "<span style=\"color:#808080\">#{h(hour)}</span>"
  end

  def format_key(k)
    case k
    when "date1"
      "Après"
    when "date2"
      "Avant"
    else
      h(k)
    end
  end

  def format_value(k, v)
    if k == "date1" or k == "date2"
      h(v.strftime("%d/%m/%Y"))
    else
      h(v)
    end
  end
end

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def get_file_name(path)
    a = path.split("/")
    if a.length <= 1 then
      ""
    else
      a[a.length-1]    
    end
  end
  
  def display_boolean(b)
    if b
      "Oui"
    else
      "Non"
    end    
  end

end

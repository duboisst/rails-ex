pprevious, pfirst, pnext, plast = navigation(params)

xml.instruct!
xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
  xml.title   "Bons de livraison"
  xml.link    "rel" => "self", "href" => bons_url(params)
  xml.link    "rel" => "alternate", "href" => bons_url(params)
  xml.link    "rel" => "first", "href" => bons_url(pfirst)
  xml.link    "rel" => "next", "href" => bons_url(pnext) if params[:page].to_i < (@total_entries / params[:per_page].to_i + 1)
  xml.link    "rel" => "previous", "href" => bons_url(pprevious) if params[:page].to_i > 1
  xml.link    "rel" => "last", "href" => bons_url(plast)
  xml.id      bons_url(params)
  #xml.updated @posts.first.updated_at.strftime "%Y-%m-%dT%H:%M:%SZ" if @posts.any?
  #xml.author  { xml.name "Author Name" }
  xml.query do
    xml.site      params[:site]
    xml.canal     params[:canal]
    xml.contenu   params[:contenu]
    xml.date1     params[:date1]
    xml.date2     params[:date2]
  end

  xml.paginate do
    xml.page          params[:page]
    xml.per_page      params[:per_page]
    xml.total_entries @total_entries
  end

  @search.each do |bon|
    xml.entry do
      xml.title     bon.title
      xml.link      "rel" => "alternate", "href" => bon_url(:escape => false, :bon => {:file => bon.file, :site => bon.site, :commande => bon.commande, :op => bon.op, :canal => bon.canal.code, :date=> bon.date})
      xml.id        bon_url(:escape => false, :bon => {:file => bon.file, :site => bon.site, :commande => bon.commande, :op => bon.op, :canal => bon.canal.code, :date=> bon.date})
      xml.updated   bon.date.strftime "%Y-%m-%d %H:%M:%S"
      xml.site      bon.site
      xml.canal do
        xml.code bon.canal.code
        xml.nom  bon.canal.name
      end
      xml.op        bon.op
      xml.commande  bon.commande
      xml.score     bon.score
      # xml.author  { xml.name "stephane dubois" }
      # xml.summary "Post summary"
      # xml.content "type" => "html" do
      #  xml.text! "blabla..."
      #end
    end
  end

end


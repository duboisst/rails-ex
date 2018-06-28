xml.instruct!
xml.ResultSet "xmlns" => "https://cable.sanofi-aventis.com",
              "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
              "xsi:schemaLocation" => "https://cable.sanofi-aventis.com http://localhost:3000/bons.xsd",
              "xmlns:xlink" => "http://www.w3.org/1999/xlink",
              "totalResultsAvailable" => @total_entries,
              "totalResultsReturned" => @search.length,
              "firstResultPosition" => @offset do
  @search.each do |bon|
    xml.Result  "xlink:href" => bon_url(:format => :xml, :escape => false, :bon => bon.to_hash),
                "xlink:title" => bon.title,
                "xlink:label" => bon_path(:format => :xml, :escape => false, :bon => bon.to_hash) do
      xml.Site       bon.site
      xml.Canal      bon.canal.name, "code" => bon.canal.code
      xml.Op         bon.op
      xml.Commande   bon.commande
      xml.Date       bon.date.strftime "%Y-%m-%d %H:%M:%S"
      xml.Score      bon.score
    end
  end
end


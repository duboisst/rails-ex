# encoding: utf-8
#require 'ferret'
#include Ferret
require 'net/http'

# Cette classe représente un bon de livraison.

class Bon

  include ApplicationHelper
  
  attr_reader  :site
  attr_reader  :canal
  attr_reader  :op
  attr_reader  :commande
  attr_reader  :file
  attr_reader  :date
  attr_reader  :score
 
  def initialize(doc, score = 0)
    @site = doc["site"][0].capitalize unless doc["site"].nil?
    @canal = Channel.find_by_code(doc["canal"][0].upcase) || Channel.new(:code => doc["canal"][0].upcase, :name => doc["canal"][0].upcase)
    @op = doc["op"][0]
    @commande = doc["commande"][0]
    @file = doc["filename"][0]
    @date = DateTime.iso8601(doc["created_on"][0]) unless doc["created_on"].nil?
    @score = score
  end

  def self.from_hash (hash)
    doc = Hash.new
    doc["site"] = [hash[:site]]
    doc["canal"] = [hash[:canal]]
    doc["op"] = [hash[:op]]
    doc["commande"] = [hash[:commande]]
    doc["filename"] = [hash[:file]]
    doc["created_on"] = [hash[:date]]
    Bon.new(doc)
  end

  def to_hash
    {:file => file, :site => site, :commande => commande, :op => op, :canal => canal.code, :date=> date}
  end
  
  # Effectue une recherche avec Ferret en fonction des paramètres passés (formulaire de recherche).
  #
  #   params[:contenu]: critère de recherche full text, ou n° d'OP ou n° de commande.
  #   params[:commande]: critère de recherche sur le n° de commande
  #   params[:op]: critère de recherche sur le n° d'OP
  #   params[:site]:    critère de recherche sur le site
  #   params[:canal]:   critère de recherche sur le canal
  #   params[:date1]:   critère de recherche sur la date (après)
  #   params[:date2]:   critère de recherche sur la date (avant)
  #   params[:page]:    page courrante
  #   params[per_page]: nombre d'entrées par page
  #   args[:channels]:  liste de cannaux autorisés. Si vide, tous les canaux sont autorisés.
  # La recherche ne retournera que les bons dont le canal correspond à un canal autorisé.
  def self.find_with_ferret(params, args = {})
    if args.empty?
      all_channels = true
    else
      all_channels = false
      channels = args[:channels]
      raise "Vous n'avez accès à aucun canal" if channels.empty?
    end

#    +site:amilly +(canal:ph canal:gf) +(op:0004500832 commande:0004500832 content:0004500832)

    records = []

    #Requete pour Ferret
    query = ""

    # Si une liste de cannaux a été passée dans args, on ajoute un critère sur ces canaux
    unless all_channels
      if channels.length > 0
        query << " +("
      end
      i=0
      for channel in channels
        query << "canal:#{channel.code} "
        i+=1
      end
      query << ")"
    end

    # Si un canal a été passé en paramètres, on ajoute un critère sur ce canal
    query << " +canal:#{params[:canal].to_s.strip}" unless params[:canal].to_s.strip.empty?

    # Si un site a été passé en paramètres, on ajoute un critère sur ce sites
    # BIDOUILLE: Comme je n'arrive pas à faire une recherche avec une query qui contient un espace,
    # je remplace les espaces par des ? (Pas génant, pour la recherche sur les sites (saint loubes))
    # entourer le site par "" devrait marcher sous solr
    query << " +site:\"#{params[:site]}\"" unless params[:site].to_s.strip.empty?
    
    # Si une date a été passée en paramètres, on ajoute un critère sur cette date
    # on renvoie tous les doc postérieurs à cette date
    query << " +created_on:[#{params[:date1].strftime("%Y%m%d")}>" unless params[:date1].nil?

    # Si une date a été passée en paramètres, on ajoute un critère sur cette date
    # on renvoie tous les doc postérieurs à cette date
    query << " +created_on:<#{params[:date2].strftime("%Y%m%d")}]" unless params[:date2].nil?

    # Si un n° de commande a été passée en paramètres, on ajoute un critère sur cette commande
    query << " +(commande:(#{params[:commande].to_s.strip}))" unless params[:commande].to_s.strip.empty?

    # Si un n° d'OP a été passé en paramètres, on ajoute un critère sur cet OP
    query << " +(op:(#{params[:op].to_s.strip}))" unless params[:op].to_s.strip.empty?

    # Si un contenu a été passé en paramètres, on ajoute un critère qui va rechercher tous les doc 
    # dont soit la commande, soit l'OP correspondent à ce contenu, ou bien qui contiennent ce contenu dans le texte du doc
   if params[:contenu].to_s.strip.match(/^\d+$/)
    query << " +(op:(#{params[:contenu].to_s.strip}) commande:(#{params[:contenu].to_s.strip}) content:(#{params[:contenu].to_s.strip}))" unless params[:contenu].to_s.strip.empty?
   else
    query << " content:(#{params[:contenu].to_s.strip})" unless params[:contenu].to_s.strip.empty?
   end
  
    params[:page] ||= 1
    params[:per_page] ||= 30

    offset = (params[:offset] || (params[:page].to_i-1) * params[:per_page].to_i).to_i
    
    # Lecture du fichier de paramétrage des index qui la forme suivante
#      -
#        site: Amilly
#        dir: d:/ff_index/amy
#        folders:
#            - D:/bl/filestoindex/amy
#            - D:/bl/filestoindex/amy2
#
#      -
#        site: Saint Loubes
#        dir: d:/ff_index/slb
#        folders:
#            - D:/bl/filestoindex/04-01
#
#      -
#        site: Marly
#        dir: d:/ff_index/mav
#        folders:
#            - D:/bl/filestoindex/mav
    #
    #
    # Pour chaque site, dir représente le nom du répertoire racine qui contient les différents index du site. Chaque sous-répertoire contient un index
    index_parameters = read_params
    readers = []
    # on compose l'index global avec tous les index de chaque site
    index_parameters.each { |index|
      index_parent_folder = index['dir']
      readers << index_parent_folder
      #Dir.glob(File.join('**', index_parent_folder)).each do |index_folder|
      #  readers << Ferret::Index::IndexReader.new(index_folder)
      #end
    }
    #multi_reader = Ferret::Index::IndexReader.new(readers)
    #searcher = Ferret::Search::Searcher.new(multi_reader)
    #begin
    #  created_on = Search::SortField.new(:created_on, :type => :byte, :reverse => true)
    #  sort = Search::Sort.new([created_on])
     # analyser = UtfAnalyzer.new()
     # queryparser = QueryParser.new(:analyser => analyser, :or_default => true)
     # parsed_query = queryparser.parse(query)

    #  total_hits = searcher.search_each(parsed_query, :limit => params[:per_page].to_i, :sort => sort, :offset => offset) do |doc, score|
    #    records << Bon.new(searcher[doc], score)
    #  end
	
	uri = URI('http://mysolr:8983/solr/cable/select/?wt=ruby&rows='+params[:per_page].to_s+'&start='+offset.to_s+'&q='+URI::encode(query))
	code = ""
	Net::HTTP.start(uri.host, uri.port) do |http|
		request = Net::HTTP::Get.new uri.request_uri
		response = http.request request
		code = response.body
	end

	rsp = eval(code)
	rsp['response']['docs'].each { |doc|
		records << Bon.new(doc, 1)
	}
	total_hits = rsp['response']['numFound']

    #ensure
    #  searcher.close
    #end

    return records, total_hits
  end

  def title
    "Site: #{site} Canal: #{canal.name} Op: #{op} Commande: #{commande}"
  end

  def invalid?
    canal_in_filename = File.basename(file, File.extname(file)).split('-')[1]
    return (canal.code.downcase != canal_in_filename.downcase)
  end

private
  def self.read_params
    open('config/index.yml') {|f| YAML.load(f) }
  end
end

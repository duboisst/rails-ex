# encoding: utf-8
require 'net/ldap'

# Cette classe représente un utilisateur de l'application.
#
# schema.rb snippet:
#  create_table "users", :force => true do |t|
#    t.string   "login"
#    t.string   "name"
#    t.boolean  "all_channels"
#    t.boolean  "is_admin"
#    t.integer  "profile_id",   :limit => 11
#    t.datetime "created_at"
#    t.datetime "updated_at"
#  end

class User < ActiveRecord::Base
  belongs_to :profile
  has_many :logs, :conditions => ["created_at > ?", Time.now - 1.month], :order => "created_at DESC"
  
  validate  :validate_user  
  validates_presence_of :login
  validates_uniqueness_of :login

  attr_accessible :login, :name, :all_channels, :is_admin, :profile_id, :created_at, :updated_at, :dn

  # true si l'utilisateur a accès à plusieurs canaux
  # et false sinon
  def multiple_channels
    if all_channels
      return true
    else
      return profile.channels.count > 1
    end   
  end
  
  # liste des canaux auxquels à accès l'utilisateur
  def channels
    if all_channels
      return Channel.find(:all)
    else
      return profile.channels
    end
  end
  
  # Vérifie d'abord les credentials (user/password) d'un utilisateur 
  # et vérifie ensuite que l'utilisateur correspondant existe dans la base 
  def self.authenticate (login, password)
    ldap = Net::LDAP.new
    ldap.port = LDAP_PORT
    ldap.host = LDAP_HOST
    ldap.encryption :simple_tls if LDAP_SSL

    # on enleve l'eventuel domaine saisi devant le login
    login.downcase!
    login = login[login.index('\\')+1..-1] if login.include?('\\')
    # on recherche dans la base le user à partir de son login
    u = User.find_by_login(login)
    # Si le user n'existe pas ==> message
    if u.nil?
      raise "Vous n'êtes pas autorisé à accéder à cette application"
    end
    # Si le user n'a pas de DN enregistré,
    # on recherche le compte correspondant au login dans le ldap pour récupérer son dn
    if u.dn.blank?
      users = ldap_search(login)
      # Si on ne le trouve pas, c'est que le login saisi n'existe pas
      if users.empty?
        raise "Utilisateur ou Mot de passe invalide"
      # Si on le trouve, on enregistre son dn
      else
        login = u.dn = "#{users[0][:dn]}"
        u.name = "#{users[0][:name]}"
        u.save!
      end
    # si l'utilisateur existe, on utilise le DN pour interroger le ldap (plus rapide)
    else
      login = u.dn
    end
    
    unless LDAP_HOST == "none"
      ldap.auth login, password
      unless ldap.bind
        u.dn = ""
        u.save!
        puts "Result: #{ldap.get_operation_result.code}"
        puts "Message: #{ldap.get_operation_result.message}"
        raise "Utilisateur ou Mot de passe invalide"
      end
    end
    
    return u
  end

  # Liste de personnes correspondant à un certain critère.
  # Le tableau retourné est un tableau de hash (login, name, mail, dn) des personnes dont
  # le nom commence par le critère ou dont le login est égal au critère
  def self.ldap_search (search)
    users = []
    if search.empty?
      return users
    end
    
    if LDAP_SSL
      encryption = :simple_tls
    else
      encryption = :none
    end
    if LDAP_HOST == "none"
      []
    else
      ldap = Net::LDAP.new :host => LDAP_HOST,
           :port => LDAP_PORT,
           :encryption => encryption,
           :auth => {
                 :method => :simple,
                 :username => LDAP_USER,
                 :password => LDAP_PASSWORD
           }
  
      # on recherche dans l'AD les users dont le nom commence par la chaine recherchée ou dont le login correspond exactement à la chaine recherchée
      filter = Net::LDAP::Filter.pres( "objectclass" ) &
               Net::LDAP::Filter.pres( "userAccountControl" ) &
               (
                 Net::LDAP::Filter.eq( "sn", "#{search}*" ) |
                 Net::LDAP::Filter.eq( "samaccountname", "#{search}" )
               )
  

      ldap.search(:base=> LDAP_BASE, :filter => filter ) do |user|
        # pour comprendre pourquoi on utilise la ruse "#{}", voir les post suivants
        # http://glu.ttono.us/articles/2007/02/26/making-net-ldap-play-nice
        # http://rubyforge.org/tracker/index.php?func=detail&aid=7602&group_id=143&atid=631

        # on exclu les comptes disabled
        next if ("#{user[:useraccountcontrol].first}".to_i & 2) == 2

        login = "#{user[:samaccountname].first}"
        name = "#{user[:cn].first}"
        mail = "#{user[:mail].first}"
        dn = "#{user[:dn].first}"
        users << {:login => login.downcase, :name => name, :mail => mail, :dn => dn}
      end
  
      users
    end

  end

private

  def validate_user
    if  !all_channels then
      if profile.nil? 
        errors.add(:base, "L'utilisateur doit avoir accès à au moins un canal. (pas de profil spécifié)")
      elsif profile.channels.count == 0
        errors.add(:base, "L'utilisateur doit avoir accès à au moins un canal. (le profil \"#{profile.name}\" n'a pas de canal)")
      end
    end
  end

end


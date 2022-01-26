require 'json'
require 'nokogiri'
require 'open-uri'
require 'pry'

class Property
  def initialize(url)
    @url = url
    @html = Nokogiri::HTML(open(url))
  end
  def get_property_info
    
  end
end 

# html = Nokogiri::HTML(open("https://www.laencontre.com.pe/agente/palo-alto-inmobiliaria-37195/venta/propiedades"))

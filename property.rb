require 'json'
require 'nokogiri'
require 'open-uri'
require 'pry'

class Property
  def initialize(url)
    @url = url
    @html = Nokogiri::HTML(open(url))
    @data = JSON.parse(File.read("data/properties.json"))
    @hash = Hash.new
  end
  def get_property_info
    @html.css("ul.listado-viviendas").children.to_a.each do |li|
      @hash[:title] = li.css('h2.title').text.strip
      @hash[:price] = li.css('p.price').text
      @data["data"].push(@hash)
    end
    File.open("data/properties.json","w") do |f|
      f.write(@data.to_json)
    end
  end
end 

# html = Nokogiri::HTML(open("https://www.laencontre.com.pe/agente/palo-alto-inmobiliaria-37195/venta/propiedades"))

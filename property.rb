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

  def get_image(property)
    property.css('div.slider_container').css('img').map { |img| img.attribute('src').value }
  end

  def get_property_info
    @html.css("ul.listado-viviendas").children.to_a.each do |li|
      next if li.text.strip == ""
      @hash[:id] = "LE-" + li.css('h2.title').css('a').attribute('href').value.split("/")[-1]
      @hash[:title] = li.css('h2.title').text.strip
      @hash[:price] = li.css('p.price').text
      @data["data"].push(@hash)
      @hash = Hash.new
    end
  end

  def generate_json
     File.open("data/properties.json","w") do |f|
      f.write(@data.to_json)
    end
  end
end 

# html = Nokogiri::HTML(open("https://www.laencontre.com.pe/agente/palo-alto-inmobiliaria-37195/venta/propiedades"))

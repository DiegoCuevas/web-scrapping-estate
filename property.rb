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

  def get_type(property)
    type = property.css('div#firstLine').css('h1').text.strip.split(" ")[0]
    {:name => type , :slug => type.downcase} 
  end

  def get_location(property)
    lat = property.css('button#see-map').attribute('data-x').value
    lng = property.css('button#see-map').attribute('data-y').value
    location = Geocoder.search([lat,lng]).first
    {
      :address => location.data["display_name"],
      :country => location.data["address"]["country"],
      :region => location.data["address"]["state"],
      :province => location.data["address"]["region"],
      :district => location.data["address"]["city"],
      :zone => '',
      :geo_point => {
          :lat => lat,
          :lon => lng
      },
      :country_slug => location.data["address"]["country"].downcase ,
      :region_slug => location.data["address"]["state"].downcase ,
      :province_slug => location.data["address"]["region"].downcase ,
      :district_slug => location.data["address"]["city"].downcase ,
      :zone_slug => ''
    }
  end

  def get_property_info
    @html.css("ul.listado-viviendas").children.to_a.each do |li|
      next if li.text.strip == ""
      @hash[:id] = "LE-" + li.css('h2.title').css('a').attribute('href').value.split("/")[-1]
      @hash[:title] = li.css('h2.title').text.strip
      @hash[:original_url] = "https://www.laencontre.com.pe" + li.css('h2.title').css('a').attribute('href').value
      @hash[:usd_price] = li.css('p.price').text
      @hash[:local_price] = ""
      @hash[:description] = li.css('p.descripcion').text.strip
      @hash[:total_area] = li.css('li.dimensions').text.strip
      @hash[:build_area] = li.css('li.dimensions').text.strip
      @hash[:bedrooms]= li.css('li.bedrooms').text.strip 
      @hash[:bathrooms]= li.css('li.bathrooms').text.strip 
      @hash[:garages]= ""
      @hash[:years_old]= ""
      
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

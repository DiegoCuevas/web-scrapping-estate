require 'json'
require 'nokogiri'
require 'open-uri'
require 'geocoder'

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
      title = li.css('h2.title').css('a').attribute('href').value
      @hash[:id] = "LE-" + title.split("/")[-1]
      @hash[:title] = li.css('h2.title').text.strip
      @hash[:original_url] = "https://www.laencontre.com.pe" + title
      price = li.css('p.price').text
      @hash[:usd_price] = price.include?("$") ? price.strip : ""
      @hash[:local_price] = price.include?("S/") ? price.strip : ""
      @hash[:description] = li.css('p.descripcion').text.strip
      @hash[:total_area] = li.css('li.dimensions').text.strip
      @hash[:build_area] = li.css('li.dimensions').text.strip
      @hash[:bedrooms]= li.css('li.bedrooms').text.strip 
      @hash[:bathrooms]= li.css('li.bathrooms').text.strip 
      @hash[:garages]= ""
      @hash[:years_old]= ""
      
      property_html = Nokogiri::HTML(open("https://www.laencontre.com.pe" + title))
      @hash[:original_pictures] = get_image(property_html)
      @hash[:property_type] = get_type(property_html)
      @hash[:location] = get_location(property_html)

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

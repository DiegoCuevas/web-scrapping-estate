require_relative 'property'


# properties = Property.new("https://www.laencontre.com.pe/agente/palo-alto-inmobiliaria-37195/venta/t-departamentos")
puts "ingrese una url"
url = gets.chomp
until url.match?(/^(http|https):\/\/|[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,6}(:[0-9]{1,5})?(\/.*)?$/)
  puts 'Ingrese una url valida'
  response = gets.chomp
end
property = Property.new(url)
property.generate_json
puts "json generado"
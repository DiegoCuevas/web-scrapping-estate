require_relative 'property'

properties = Property.new("https://www.laencontre.com.pe/agente/palo-alto-inmobiliaria-37195/venta/propiedades")
properties.get_property_info
properties.generate_json

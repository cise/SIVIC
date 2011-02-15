# db/fixtures/rooms.rb
# put as many seeds as you like in

Room.all.map(&:destroy)

Room.seed(:name, :description) do |s|
  s.name = "Aula Satelital ESPOL" 
  s.description = "Aula Satelital ESPOL" 
  s.country = "Ecuador"
  s.city = "Guayaquil"
  s.location = "Km. 30.5 via Perimetral. Campus Gustavo Galindo Velasco"
  s.service_type = "Not certified"
  s.ip_address = "127.0.0.1"
  s.uri = "http://127.0.0.1"
  s.lng = "-2.151781"
  s.lat = "-79.956539"
end

Room.seed(:name, :description) do |s|
  s.name = "Aula Satelital ESPE"
  s.description = "Aula Satelital ESPE"
  s.country = "Ecuador"
  s.city = "Quito"
  s.location = "Av. Gral. Rumiñahui s/n Sangolquí"
  s.service_type = "Not certified"
  s.ip_address = "127.0.0.1"
  s.uri = "http://127.0.0.1"
  s.lng = "-0.314364"
  s.lat = "-78.445162"
end

Room.seed(:name, :description) do |s|
  s.name = "REACCIUN"
  s.description = "Aula Satelital Red Académica Nacional"
  s.country = "Venezuela"
  s.city = "Caracas"
  s.location = "Av. Universidad, Esquina El Chorro, Torre Ministerial, Piso 11"
  s.service_type = "Not certified"
  s.ip_address = "127.0.0.1"
  s.uri = "http://127.0.0.1"
  s.lng = "10.485072"
  s.lat = "-66.891401"
end


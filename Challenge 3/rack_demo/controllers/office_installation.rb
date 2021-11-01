require 'pg'
require 'erb'


class OfficeInstallation
  def call(env)
    request = Rack::Request.new(env)
    index(request, env)
  end

  def index(request, env)
    $conn = PG.connect(:dbname => 'bank_system', :password => 'apple', :port => 5432, :user => 'postgres')
    template = File.read('views/office_installation.html.erb')
    begin
      @office = $conn.exec("SELECT title, state, address, phone, type FROM offices WHERE id = #{env['rack.route_params'][:id]}")[0]


      zones = $conn.exec(
        "SELECT type, id FROM zones WHERE office_id = #{env['rack.route_params'][:id]}"
      )

      rooms = Hash.new
      @response_hash = Hash.new

      zones.each do |data|
        rooms[data["type"]] = $conn.exec(
          "SELECT name, id FROM rooms WHERE zone_id = #{data["id"]}"
          )
      end

      rooms.each do |key, value|
        # puts "#{key} => "
        temp = Hash.new
        value.each do |data|
          # puts data
          # puts "------------"
          marketing_material_fixtures = $conn.exec(
            "SELECT mm.type marketing_material_type, mm.name marketing_material_name, fix.name fixture_name, fix.type fixture_type
             FROM (( rooms
             INNER JOIN fixtures fix ON rooms.id = fix.room_id)
             INNER JOIN marketing_material mm ON fix.id = mm.fixture_id)
             WHERE rooms.id = #{data["id"]}"
          )

          temp.store(data["name"], marketing_material_fixtures)
          @response_hash[key] = temp

        end

      end

      @response_hash.each do |key, value|
        puts "#{key} => "
        value.each do |k, v|
          puts
          print "#{k} -->"
          v. each do |data|
            puts data
          end
          puts "-----------"
        end
      end

      body = ERB.new(template)
      [200, {"Content-Type" => "text/html"}, [body.result(binding)]]
    rescue IndexError
      [200, {"Content-Type" => "text/html"}, ["<h1>ERROR: Non-existent id in url parameters. Change params!</h1>"]]
    end
  end
end

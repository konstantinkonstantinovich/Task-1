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

      zones.each do |data|

      end


      mf = []

      mf << $conn.exec(
          "SELECT mm.type marketing_material_type, mm.name marketing_material_name, fix.name fixture_name, fix.type fixture_type
           FROM (((( offices
           INNER JOIN zones ON offices.id = zones.office_id)
           INNER JOIN rooms ON zones.id = rooms.zone_id)
           INNER JOIN fixtures fix ON rooms.id = fix.room_id)
           INNER JOIN marketing_material mm ON fix.id = mm.fixture_id)
           WHERE offices.id = #{env['rack.route_params'][:id]};
           "
        )



      result = nil

      result = $conn.exec(
        "SELECT row_to_json(o)
        FROM (
            SELECT zones.type,
             (
              SELECT array_to_json(array_agg(row_to_json(z)))
              FROM (
                SELECT rooms.name,
                (
                  SELECT array_to_json(array_agg(row_to_json(r)))
                  FROM (
                    SELECT fixtures.type, fixtures.name
                    FROM fixtures
                    WHERE room_id = rooms.id


                  ) r

                ) as rooms

                FROM rooms
                WHERE rooms.zone_id = zones.id
              ) z

             ) as zone
            FROM zones
            WHERE zones.office_id = #{env['rack.route_params'][:id]}
        ) o;"
      )

      body = ERB.new(template)
      [200, {"Content-Type" => "text/html"}, [body.result(binding)]]
    rescue IndexError
      [200, {"Content-Type" => "text/html"}, ["<h1>ERROR: Non-existent id in url parameters. Change params!</h1>"]]
    end
  end
end

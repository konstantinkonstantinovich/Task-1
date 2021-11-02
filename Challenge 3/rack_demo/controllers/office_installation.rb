require 'pg'
require 'erb'
require './controllers/render'

class OfficeInstallationRoot

  include Render

  def db_connect
    conn = PG.connect(:dbname => 'bank_system', :password => 'apple', :port => 5432, :user => 'postgres')
  end

  def call(env)
    request = Rack::Request.new(env)
    index(request, env)
  end

  def index(request, env)
    conn = db_connect

    @response = nil
    if request.post? && request.POST["text"].length != 0
      params = request.POST
      @response = conn.exec("
        ALTER TABLE offices ADD COLUMN IF NOT EXISTS ts tsvector
            GENERATED ALWAYS AS
                (setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
                 setweight(to_tsvector('english', coalesce(address, '')), 'B')) STORED;

        SELECT id, title, state, phone, address, type
        FROM offices
        WHERE ts @@ to_tsquery('english', '#{params["text"]}');
        ")
    else
      @response = conn.exec(
        "SELECT id, title FROM offices"
      )

    end

    render_template 'views/root_installation.html.erb'
  end

end

class OfficeInstallation

  include Render

  def db_connect
    conn = PG.connect(:dbname => 'bank_system', :password => 'apple', :port => 5432, :user => 'postgres')
  end

  def call(env)
    request = Rack::Request.new(env)
    index(request, env)
  end

  def index(request, env)
    conn = db_connect
    begin
      @office = conn.exec("SELECT title, state, address, phone, type FROM offices WHERE id = #{env['rack.route_params'][:id]}")[0]

      zones = conn.exec(
        "SELECT type, id FROM zones WHERE office_id = #{env['rack.route_params'][:id]}"
      )

      rooms = Hash.new
      @response_hash = Hash.new

      zones.each do |data|
        rooms[data["type"]] = conn.exec(
          "SELECT name, id FROM rooms WHERE zone_id = #{data["id"]}"
        )
      end

      rooms.each do |key, value|
        temp = Hash.new
        value.each do |data|
          marketing_material_fixtures = conn.exec(
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

      @sum = conn.exec(
        "SELECT SUM(rooms.area) area, SUM(rooms.max_people) people
         FROM (( offices
           INNER JOIN zones ON offices.id = zones.office_id)
           INNER JOIN rooms ON zones.id = rooms.zone_id)
           WHERE offices.id = #{env['rack.route_params'][:id]};"
      )

      render_template 'views/office_installation.html.erb'
    rescue IndexError
      [200, { "Content-Type" => "text/html" }, ["<h1>ERROR: Non-existent id in url parameters. Change params!</h1>"]]
    end
  end
end

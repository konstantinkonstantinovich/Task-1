require 'pg'
require 'erb'
require './render'
require './pg_connect'

class OfficeInstallationRoot
  include Render

  def call(env)
    request = Rack::Request.new(env)
    index(request)
  end

  private

  def index(request)
    @response = nil
    if request.post? && request.POST["text"].length != 0
      params = request.POST
      @response = CONN.exec("
        SELECT id, title, state, phone, address, type
        FROM offices
        WHERE ts @@ to_tsquery('english', '#{params["text"]}');
        ")
    else
      @response = CONN.exec(
        "SELECT id, title FROM offices"
      )

    end

    render_template 'views/root_installation.html.erb'
  end
end

class OfficeInstallation
  include Render

  def call(env)
    request = Rack::Request.new(env)
    index(env)
  end

  def index(env)
    begin
      @office = CONN.exec("SELECT title, state, address, phone, type FROM offices WHERE id =
        #{env['rack.route_params'][:id]}")[0]

      zones = CONN.exec(
        "SELECT type, id FROM zones WHERE office_id = #{env['rack.route_params'][:id]}"
      )

      rooms = {}
      @response_hash = {}

      zones.each do |data|
        rooms[data["type"]] = CONN.exec(
          "SELECT name, id FROM rooms WHERE zone_id = #{data["id"]}"
        )
      end

      rooms.each do |key, value|
        temp = Hash.new
        value.each do |data|
          marketing_material_fixtures = CONN.exec(
            "SELECT mm.type marketing_material_type, mm.name marketing_material_name,
             fix.name fixture_name, fix.type fixture_type
             FROM (( rooms
             INNER JOIN fixtures fix ON rooms.id = fix.room_id)
             INNER JOIN marketing_material mm ON fix.id = mm.fixture_id)
             WHERE rooms.id = #{data["id"]}"
          )
          temp.store(data["name"], marketing_material_fixtures)
          @response_hash[key] = temp
        end
      end

      @sum = CONN.exec(
        "SELECT SUM(rooms.area) area, SUM(rooms.max_people) people
         FROM (( offices
           INNER JOIN zones ON offices.id = zones.office_id)
           INNER JOIN rooms ON zones.id = rooms.zone_id)
           WHERE offices.id = #{env['rack.route_params'][:id]};"
      )

      render_template 'views/office_installation.html.erb'
    rescue IndexError
      [200, { 'Content-Type' => 'text/html' }, ["<h1>ERROR: Non-existent id in url parameters. Change params!</h1>"]]
    end
  end
end

require 'pg'
require 'erb'
require './render'
require './pg_connect'


class FixtureReport
  include Render

  def call(env)
    request = Rack::Request.new(env)
    index request, env
  end

  def index(request, env)
    begin
      @new_hash = {}
      @office_title = CONN.exec("SELECT title FROM offices WHERE id = #{env['rack.route_params'][:id]}")[0]

      puts @office_title

      @new_hash[@office_title["title"]] = CONN.exec(
        "SELECT fixtures.type
        FROM ((( offices
        INNER JOIN zones ON offices.id = zones.office_id)
        INNER JOIN rooms ON zones.id = rooms.zone_id)
        INNER JOIN fixtures ON rooms.id = fixtures.room_id)
        WHERE offices.id = #{env['rack.route_params'][:id]};
        "
      )

      @new_hash.each { |key, value| @new_hash[key] = value.inject(Hash.new(0)) { |memo, i| memo[i] += 1; memo } }

      @total_count = 0
      @new_hash.each do |key, value|
        puts "#{key} => "
        value.each do |_k, v|
          @total_count += v
        end
      end

      render_template 'views/fixture.html.erb'
    rescue IndexError
      [200, { 'Content-Type' => 'text/html'  }, ["<h1>ERROR: Non-existent id in url parameters. Change params!</h1>"]]
    end
  end
end

require 'pg'
require 'erb'
require './controllers/render'

class AllFixture

  include Render

  def db_connect
    conn = PG.connect(:dbname => 'bank_system', :password => 'apple', :port => 5432, :user => 'postgres')
  end

  def call(env)
    request = Rack::Request.new(env)
    index request
  end

  def index(request)
    conn = db_connect

    # get all fixtures data
    @fixtures = conn.exec(
      "SELECT * FROM fixtures"
    )

    # create hash for inserting type of
    # fixtures like key and value like
    # offices data
    @office = Hash.new { |h, k| h[k] = [] }

    @fixtures.each do |data|
      @office[data['type']] << conn.exec(
        "SELECT * FROM offices WHERE id = (SELECT office_id FROM zones WHERE id = (SELECT zone_id FROM rooms WHERE id = '#{data['room_id']}'))"
      )[0]
    end

    @total_count = []

    @office.each do |key, value|
      @total_count.push(conn.exec(
        "SELECT COUNT(*) FROM fixtures WHERE type = '#{key}'"
      ))
    end

    @office.each { |key, value| @office[key] = value.inject(Hash.new(0)) { |memo, i| memo[i] += 1; memo } }

    render_template 'views/fixtures.html.erb'
  end
end

class FixtureReport

  include Render

  def db_connect
    conn = PG.connect(:dbname => 'bank_system', :password => 'apple', :port => 5432, :user => 'postgres')
  end

  def call(env)
    request = Rack::Request.new(env)
    index request, env
  end

  def index(request, env)
    conn = db_connect

    begin
      @new_hash = Hash.new
      @office_title = conn.exec("SELECT title FROM offices WHERE id = #{env['rack.route_params'][:id]}")[0]

      puts @office_title

      @new_hash[@office_title["title"]] = conn.exec(
        "SELECT fixtures.type
        FROM ((( offices
        INNER JOIN zones ON offices.id = zones.office_id)
        INNER JOIN rooms ON zones.id = rooms.zone_id)
        INNER JOIN fixtures ON rooms.id = fixtures.room_id)
        WHERE offices.id = #{env['rack.route_params'][:id]};
        ")

      @new_hash.each { |key, value| @new_hash[key] = value.inject(Hash.new(0)) { |memo, i| memo[i] += 1; memo } }

      @total_count = 0
      @new_hash.each do |key, value|
        puts "#{key} => "
        value.each do |k, v|
          @total_count += v
        end
      end

      render_template 'views/fixture.html.erb'
    rescue IndexError
      [200, { "Content-Type" => "text/html" }, ["<h1>ERROR: Non-existent id in url parameters. Change params!</h1>"]]
    end

  end

end

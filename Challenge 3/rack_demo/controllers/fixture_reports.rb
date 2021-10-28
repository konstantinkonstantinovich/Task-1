require 'pg'
require 'erb'

class AllFixture
  def call(env)
    request = Rack::Request.new(env)
    index request, env
  end

  def index(request, env)
    $conn = PG.connect(:dbname => 'bank_system', :password => 'apple', :port => 5432, :user => 'postgres')
    template = File.read('views/fixtures.html.erb')

    # get all fixtures data

    @fixtures = $conn.exec(
      "SELECT * FROM fixtures"
    )

    # create hash for inserting type of
    # fixtures like key and value like
    # offices data
    @office = Hash.new {|h,k| h[k]=[]}

    @fixtures.each do |data|
      @office[data['type']] << $conn.exec(
        "SELECT * FROM offices WHERE id = (SELECT office_id FROM zones WHERE id = (SELECT zone_id FROM rooms WHERE id = '#{data['room_id']}'))"
      )[0]
    end

    @total_count = []

    @office.each do |key, value|
        @total_count.push($conn.exec(
          "SELECT COUNT(*) FROM fixtures WHERE type = '#{key}'"
        ))
    end

    @office.each { |key, value| @office[key] = value.inject(Hash.new(0)) { |memo, i| memo[i] += 1; memo } }

    # @office.each do |key, value|
    #   @office[key] = value.inject(Hash.new(0)) { |memo, i| memo[i] += 1; memo }
    # end

    body = ERB.new(template)
    [200, {"Content-Type" => "text/html"}, [body.result(binding)]]
  end
end


class FixtureReport
  def call(env)
    request = Rack::Request.new(env)
    index request, env
  end

  def index(request, env)
    $conn = PG.connect(:dbname => 'bank_system', :password => 'apple', :port => 5432, :user => 'postgres')
    template = File.read('views/fixture.html.erb')

    begin
      zones_id = $conn.exec(
        "SELECT id FROM zones WHERE office_id = #{env['rack.route_params'][:id]}"
      )

      @office_title = $conn.exec("SELECT title FROM offices WHERE id = #{env['rack.route_params'][:id]}")

      rooms_id = []
      zones_id.each do |data|
        puts "#{data["id"]} - zone"
        rooms_id.push($conn.exec(
          "SELECT id FROM rooms WHERE zone_id = #{data["id"]}"
        ))
      end

      @fixture_type = []
      rooms_id.each do |data|
        data.each do |room|
          puts "#{room["id"]} - room"
          @fixture_type.push($conn.exec("SELECT * FROM fixtures WHERE room_id = #{room["id"]}"))
        end
      end

      @fixture_type.each do |data|
        data.each do |fixture|
          puts fixture
        end
      end

      body = ERB.new(template)
      [200, {"Content-Type" => "text/html"}, [body.result(binding)]]

    rescue IndexError
      [200, {"Content-Type" => "text/html"}, ["<h1>ERROR: Non-existent id in url parameters. Change params!</h1>"]]
    end

  end

end

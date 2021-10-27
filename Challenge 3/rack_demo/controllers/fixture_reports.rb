require 'pg'
require 'erb'

class AllFixture
  def call(env)
    request = Rack::Request.new(env)
    index request, env
  end

  def index(request, env)
    $conn = PG.connect(:dbname => 'bank_system', :password => 'apple', :port => 5432, :user => 'postgres')
    template = File.read('views/fixture.html.erb')

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
      )
    end

    @total_count = []

    @office.each do |key, value|
        @total_count.push($conn.exec(
          "SELECT COUNT(*) FROM fixtures WHERE type = '#{key}'"
        ))
    end

    body = ERB.new(template)
    [200, {"Content-Type" => "text/html"}, [body.result(binding)]]
  end
end

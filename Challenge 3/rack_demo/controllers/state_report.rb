require 'pg'
require 'erb'
require './controllers/render'


class StateReport

  include Render

  def db_connect
    conn = PG.connect(:dbname => 'bank_system', :password => 'apple', :port => 5432, :user => 'postgres')
  end

  def call(env)
    request = Rack::Request.new(env)
    index(request, env)
  end

  def index(request, env)
    $conn = db_connect

    # Make a request to Postgres db
    # to find all offices with a certain STATE

    if env['REQUEST_URI'] == '/reports/states/ca' or env['REQUEST_URI'] == '/reports/states/ny'
      @result = $conn.exec(
        "SELECT * from offices WHERE state = '#{env['rack.route_params'][:state].upcase}' "
      )
    else
      Rack::Response.new(
        "<h1>Incorrect Url: No result for this url #{env['REQUEST_URI']}</h1> ",
        200,
        {"Content-Type" => "text/html"})
    end

    render_template 'views/index.html.erb'
  end

end


class AllStates

  include Render

  def db_connect
    conn = PG.connect(:dbname => 'bank_system', :password => 'apple', :port => 5432, :user => 'postgres')
  end

  def call(env)
    request = Rack::Request.new(env)
    index(request, env)
  end

  def index(request, env)
    $conn = db_connect

    all_office = $conn.exec(
      "SELECT state FROM offices"
    )

    array = []
    all_office .each { |data|  array.push(data["state"])}
    array.uniq!

    # Make a request to Postgres db
    # to find all offices with a certain STATE
    @offices = []
    array.each do |data|
      @offices.push($conn.exec(
        "SELECT * FROM offices WHERE state = '#{data}'"
      ))
    end

    render_template 'views/all_states.html.erb'
  end
end

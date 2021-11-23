require 'pg'
require 'erb'
require './render'
require './pg_connect'

class StateReport
  include Render

  def call(env)
    request = Rack::Request.new(env)
    index(request, env)
  end

  private

  def index(request, env)
    # Make a request to Postgres db
    # to find all offices with a certain STATE

    begin
      @result = CONN.exec(
        "SELECT * from offices WHERE state = '#{env['rack.route_params'][:state].upcase}' "
      )
      render_template 'views/index.html.erb'
    rescue IndexError
       [200, { 'Content-Type' => 'text/html' }, ["<h1>Incorrect Url: Unknown state!</h1> "]]
    end
  end
end

class AllStates
  include Render

  def call(env)
    request = Rack::Request.new(env)
    index
  end

  private

  def index
    all_office = CONN.exec(
      'SELECT state FROM offices'
    )

    array = []
    all_office.each { |data| array.push(data["state"]) }
    array.uniq!

    # Make a request to Postgres db
    # to find all offices with a certain STATE
    @offices = []
    array.each do |data|
      @offices.push(CONN.exec(
                      "SELECT * FROM offices WHERE state = '#{data}'"
                    ))
    end

    render_template 'views/all_states.html.erb'
  end
end

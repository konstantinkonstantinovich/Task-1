require 'pg'
require 'erb'
require './render'
require './pg_connect'

class AllFixtures
  include Render

  def call(env)
    request = Rack::Request.new(env)
    index request
  end

  private

  def index(request)
    fixture = CONN.exec(
         "SELECT title, address, lob, office.type office_type, fixtures.type fixture_type
         FROM ((( fixtures
         INNER JOIN rooms ON rooms.id = fixtures.room_id)
         INNER JOIN zones ON zones.id = rooms.zone_id)
         INNER JOIN offices office ON office.id = zones.office_id);"
    )

    @fixtures_hash = {}
    fixture.each do |data|
      @fixtures_hash[data["fixture_type"]] = []
    end

    @fixtures_hash.each do |key, value|
      fixture.each do |data|
        if data["fixture_type"] == key
          value.push(
            {"lob" => data["lob"],
             "address" => data["address"],
             "title" => data["title"],
             "type" => data["office_type"]}
          )
        end
      end
    end

    @fixtures_hash.each { |key, value| @fixtures_hash[key] = value.inject(Hash.new(0)) { |memo, i| memo[i] += 1; memo } }

    @total_count = []
    @fixtures_hash.each do |key, value|
      total = 0
      value.each do |k, v|
        total += v
      end
      @total_count << total
    end

    render_template 'views/fixtures.html.erb'
  end
end

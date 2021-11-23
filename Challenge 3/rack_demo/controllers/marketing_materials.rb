require 'pg'
require 'erb'
require './render'
require './pg_connect'

class MarketingMaterialsReport
  include Render

  def call(env)
    request = Rack::Request.new(env)
    index(request)
  end

  private

  def index(request)
    @marketing_materials = Hash.new { |h, k| h[k] = [] }

    offices_title = CONN.exec("SELECT title, id FROM offices")

    @new_hash = {}
    result = {}
    offices_title.each do |data|
      result[data["title"]] = CONN.exec(
        "SELECT marketing_material.type, marketing_material.cost
         FROM (((( offices
         INNER JOIN zones ON offices.id = zones.office_id)
         INNER JOIN rooms ON zones.id = rooms.zone_id)
         INNER JOIN fixtures ON rooms.id = fixtures.room_id)
         INNER JOIN marketing_material ON fixtures.id = marketing_material.fixture_id)
         WHERE offices.id = #{data["id"]};
         "
      )
      @new_hash[data["title"]] = {}
    end

    @total_cost = []

    result.each do |key, value|
      temp = 0
      value.each do |data|
        @new_hash[key][data["type"]] ?
        @new_hash[key][data["type"]] += data["cost"].to_i :
        @new_hash[key][data["type"]] = data["cost"].to_i
        temp += data["cost"].to_i
      end
      @total_cost << temp
    end

    @labels = Hash.new { |h, k| h[k] = [] }
    @data = Hash.new { |h, k| h[k] = [] }
    @new_hash.each do |key, value|
      value.each do |k, v|
        @labels[key] << k
        @data[key] << v
      end
    end

    render_template 'views/marketing_materials.html.erb'
  end
end

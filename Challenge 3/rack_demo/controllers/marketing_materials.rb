require 'pg'
require 'erb'


class MarketingMaterialsReport
  def call(env)
    request = Rack::Request.new(env)
    index(request, env)
  end

  def index(request, env)
    $conn = PG.connect(:dbname => 'bank_system', :password => 'apple', :port => 5432, :user => 'postgres')
    template = File.read('views/marketing_materials.html.erb')

    @marketing_materials = Hash.new {|h,k| h[k]=[]}

    @office_title = $conn.exec("SELECT title, id FROM offices")

    @new_hash = Hash.new
    @result = Hash.new
    @office_title.each do |data|
       @result[data["title"]] = $conn.exec(
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

    @result.each do |key, value|
      temp = 0
      value.each do |data|
        @new_hash[key][data["type"]] ? @new_hash[key][data["type"]] += data["cost"].to_i : @new_hash[key][data["type"]] = data["cost"].to_i
        temp += data["cost"].to_i
      end
      @total_cost << temp
    end


    # print @total_cost
    #

    @labels = Hash.new {|h,k| h[k]=[]}
    @data = Hash.new {|h,k| h[k]=[]}
    @new_hash.each do |key, value|
      value.each do |k, v|
        @labels[key] << k
        @data[key] << v
      end
    end


    body = ERB.new(template)
    [200, {"Content-Type" => "text/html"}, [body.result(binding)]]
  end

end

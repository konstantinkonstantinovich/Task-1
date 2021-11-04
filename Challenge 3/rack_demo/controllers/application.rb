require 'csv'
require 'pg'
require 'erb'
require './controllers/render'

class App

  include Render

  def db_connect
    conn = PG.connect(:dbname => 'bank_system', :password => 'apple', :port => 5432, :user => 'postgres')
  end

  # function, that parse data from uploaded CSV file
  def parse(path)
    table = CSV.parse(File.read(path), headers: true)
  end

  def call(env)
    request = Rack::Request.new(env)
    index(request)
  end

  def index(request)
    # connect to Postgres
    conn = db_connect

    if request.post?
      table = parse(request.params['file'][:tempfile])

      # insert offices data from file CSV

      table.by_row.each do |data|
        begin
          office = conn.exec_params("INSERT INTO offices (id, title, address, city, state, phone, lob, type)
              VALUES (DEFAULT,
                $1,
                '#{data['Office address']}',
                '#{data['Office city']}',
                '#{data['Office State']}',
                #{data['Office phone'].to_i},
                '#{data['Office lob']}',
                '#{data['Office type']}')", [data["Office"]])
        rescue PG::UniqueViolation
          next
        end
      end

      # insert zones data from file CSV

      table.by_row.each do |data|
        begin
          #{data['Zone']}
          #{data['Office']}
          zones = conn.exec_params(
            "INSERT INTO zones (id, type, office_id)
             VALUES (DEFAULT,
               $1,
               (SELECT id from offices WHERE title = $2));",
               [data['Zone'], data["Office"]]
          )
        rescue
          next PG::UniqueViolation
        end
      end

      # insert rooms data from file CSV

      table.by_row.each do |data|
        begin
          rooms = conn.exec_params(
            "INSERT INTO rooms (id, name, area, max_people, zone_id)
             VALUES (
               DEFAULT,
               '#{data['Room']}',
               '#{data['Room area']}',
               '#{data['Room max people']}',
               (SELECT id FROM zones
                WHERE (zones.type = '#{data['Zone']}'
                  AND zones.office_id = (SELECT id from offices WHERE title = $1))));",
            [data["Office"]]
          )
        rescue
          next PG::UniqueViolation
        end
      end

      # insert fixtures data from file CSV

      table.by_row.each do |data|
        begin
          fixtures = conn.exec_params(
            "INSERT INTO fixtures (id, name, type, room_id)
             VALUES (
               DEFAULT,
               '#{data['Fixture']}',
               '#{data['Fixture Type']}',
               (SELECT id FROM rooms
                WHERE ( rooms.name = '#{data['Room']}'
                AND rooms.zone_id = (SELECT id from zones
                  WHERE (type = '#{data['Zone']}'
                  AND office_id = (SELECT id from offices WHERE title = $1))))));",
            [data["Office"]]
          )
        rescue PG::InvalidTextRepresentation
          next
        end
      end

      # insert marketing_material data from file CSV

      table.by_row.each do |data|
        begin
          conn.exec_params(
            "INSERT INTO marketing_material (id, name, type, cost, fixture_id)
             VALUES (
               DEFAULT,
               '#{data['Marketing material']}',
               '#{data['Marketing material type']}',
                #{data['Marketing material cost'].to_i},
               (SELECT id FROM fixtures
                 WHERE name = '#{data['Fixture']}'
                 AND room_id = (SELECT id FROM rooms
                  WHERE ( rooms.name = '#{data['Room']}'
                    AND rooms.zone_id = (SELECT id from zones
                      WHERE (type = '#{data['Zone']}'
                      AND office_id = (SELECT id from offices WHERE title = $1)))))));",
            [data["Office"]]
          )
        rescue PG::CardinalityViolation
          next
        end
      end
    end

    render_template 'views/upload.html.erb'
  end
end

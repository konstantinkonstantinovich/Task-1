#config.ru
require 'csv'
require 'pg'


class App
  # function, that parse data from uploaded CSV file
  def parse(path)
    table = CSV.parse(File.read(path), headers: true)
  end

  def call(env)
    request = Rack::Request.new(env)

    # connect to Postgres
    $conn = PG.connect(:dbname => 'bank_system', :password => 'apple', :port => 5432, :user => 'postgres')

    if request.post?
      table = parse(request.params['file'][:tempfile])

      # insert offices data from file CSV
      table.by_row.each do |data|
        begin
          office = $conn.exec("INSERT INTO offices (id, title, address, city, state, phone, lob, type)
              VALUES (DEFAULT,
                '#{data['Office']}',
                '#{data['Office address']}',
                '#{data['Office city']}',
                '#{data['Office State']}',
                #{data['Office phone'].to_i},
                '#{data['Office lob']}',
                '#{data['Office type']}')")
        rescue PG::UniqueViolation
          next
        end
      end

      # insert zones data from file CSV
      table.by_row.each do |data1|
        begin
          zones = $conn.exec(
            "INSERT INTO zones (id, type, office_id)
             VALUES (DEFAULT,
               '#{data1['Zone']}',
               (SELECT id from offices WHERE title = '#{data1['Office']}'));"
          )
        rescue
          next PG::UniqueViolation
        end
      end

      # insert rooms data from file CSV
      table.by_row.each do |data2|
        begin
          rooms = $conn.exec(
            "INSERT INTO rooms (id, name, area, max_people, zone_id)
             VALUES (
               DEFAULT,
               '#{data2['Room']}',
               '#{data2['Room area']}',
               '#{data2['Room max people']}',
               (SELECT id FROM zones
                WHERE (zones.type = '#{data2['Zone']}'
                  AND zones.office_id = (SELECT id from offices WHERE title = '#{data2['Office']}'))));"
          )
        rescue
          next PG::UniqueViolation
        end
      end

      # insert fixtures data from file CSV

      table.by_row.each do |data|
        begin

          fixtures = $conn.exec(
            "INSERT INTO fixtures (id, name, type, room_id)
             VALUES (
               DEFAULT,
               '#{data['Fixture']}',
               '#{data['Fixture Type']}',
               (SELECT id FROM rooms
                WHERE ( rooms.name = '#{data['Room']}'
                AND rooms.zone_id = (SELECT id from zones
                  WHERE type = '#{data['Zone']}'
                  AND zones.office_id = (SELECT id from offices WHERE title = '#{data['Office']}')))));"
          )
        rescue
          next PG::UniqueViolation
        end
      end
    end


    status  = 200
    headers = { "Content-Type" => "text/html" }
    body    = ["
      <h1>Challenge 3(Advanced)</h1>
      <form method='post' enctype='multipart/form-data'>
       <div>
         <label for='file'>Choose file to upload</label>
         <input type='file' id='file' name='file' multiple>
       </div>
       <div>
         <button>Submit</button>
       </div>
      </form>
      "]
    [status, headers, body]
  end


end

# application routing
app = Rack::URLMap.new('/index'  => App.new)

run app


# fixture = $conn.exec(
#   "INSERT INTO fixtures (id, name, type, room_id)
#               VALUES (DEFAULT,
#                 '#{data['Fixture']}',
#                 '#{data['Fixture Type']}',
#                 '#{room[0]['id']}'
#                 )
#                 returning id;"
# )

#config.ru

require 'json'
require 'csv'
require 'pg'


class App
  def parse(path)
    table = CSV.parse(File.read(path), headers: true)
  end

  def call(env)
    req = Rack::Request.new(env)
    $conn = PG.connect(:dbname => 'bank_system', :password => 'apple', :port => 5432, :user => 'postgres')
    if req.post?
      table = parse(req.params['file'][:tempfile])
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
                '#{data['Office type']}')
                returning id;")


                  zone = $conn.exec("INSERT INTO zones (id, type, office_id)
                            VALUES (DEFAULT,
                              '#{data['Zone']}',
                              '#{office[0]['id']}')
                              returning id;")
        rescue PG::UniqueViolation
          next
        end
        room = $conn.exec(
          "INSERT INTO rooms (id, name, area, max_people, zone_id)
                      VALUES (DEFAULT,
                        '#{data['Room']}',
                        '#{data['Room area']}',
                        '#{data['Room max people']}',
                        '#{zone[0]['id']}'
                        )
                        returning id;"
        )
        fixture = $conn.exec(
          "INSERT INTO fixtures (id, name, type, room_id)
                      VALUES (DEFAULT,
                        '#{data['Fixture']}',
                        '#{data['Fixture Type']}',
                        '#{room[0]['id']}'
                        )
                        returning id;"
        )

      end
    end


    status  = 200
    headers = { "Content-Type" => "text/html" }
    body    = ["
      <h1>Upload file</h1>
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
app = Rack::URLMap.new('/index'  => App.new)
run app

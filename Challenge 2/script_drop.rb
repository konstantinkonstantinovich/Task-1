require 'pg'

conn = PG.connect(:dbname => 'bank_system', :password => 'apple', :port => 5432, :user => 'postgres')

drop = conn.exec(
    'DROP TABLE IF EXISTS offices, zones, rooms, fixtures, marketing_material;
     DROP TYPE IF EXISTS type_fixture'
)

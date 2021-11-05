require 'pg'

CONN = PG.connect(dbname: 'bank_system', password: 'apple', port: 5432, user: 'postgres')

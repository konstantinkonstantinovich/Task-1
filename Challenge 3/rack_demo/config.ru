#config.ru
require './application'
require 'csv'
require 'pg'
require 'erb'

# application routing
app = Rack::URLMap.new('/'  => App.new,
                       '/reports/states/' => Challenge4.new
)

run app

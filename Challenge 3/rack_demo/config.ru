#config.ru
require './controllers/application'
require './controllers/state_report'
require './controllers/fixture_reports.rb'
require 'rack/router'


# application routing
app = Rack::Router.new {
  post '/'=>App.new
  get '/reports/states'=>AllStates.new
  get '/reports/states/:state'=>StateReport.new
  get '/reports/offices/fixture_types'=>AllFixture.new
  get '/reports/offices/:id/fixture_types' => FixtureReport.new
}

run app

# config.ru
require './controllers/application'
require './controllers/state_report'
require './controllers/fixture_reports'
require './controllers/fixture_report'
require './controllers/marketing_materials'
require './controllers/office_installation'
require 'rack/router'

use Rack::Static,
    :urls => ["/css"],
    :root => "public"

# application routing
app = Rack::Router.new {
  get '/' => Application.new
  post '/' => Application.new
  get '/reports/states' => AllStates.new
  get '/reports/states/:state' => StateReport.new
  get '/reports/offices/fixture_types' => AllFixtures.new
  get '/reports/offices/:id/fixture_types' => FixtureReport.new
  get '/reports/offices/marketing_materials' => MarketingMaterialsReport.new
  get '/reports/offices/installation' => OfficeInstallationRoot.new
  post '/reports/offices/installation' => OfficeInstallationRoot.new
  get '/reports/offices/:id/installation' => OfficeInstallation.new
}

run app

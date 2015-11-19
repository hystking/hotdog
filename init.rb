#!/usr/bin/env ruby

require 'active_support/all'

appname = ARGV.first

AppName = appname.camelize
app_name = appname.underscore
APP_NAME = app_name.upcase

FILES = [
  "./app/views/layouts/application.html.erb",
  "./config/application.rb",
  "./config/database.yml",
  "./config/initializers/session_store.rb",
].join " "

`sed -i '' -e 's/Hotdog/#{AppName}/g' #{FILES}`
`sed -i '' -e 's/hotdog/#{app_name}/g' #{FILES}`
`sed -i '' -e 's/HOTDOG/#{APP_NAME}/g' #{FILES}`

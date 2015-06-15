require 'angular'
Editor = require './controllers/editor'

app = angular.module 'dockerfileEditor', []

app.controller 'Editor', Editor

module.exports = app;
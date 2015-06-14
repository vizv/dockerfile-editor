app = require '../app'

app.controller 'Editor', ['$scope', ($scope) ->
  $scope.test = ->
    console.log 'test'
]

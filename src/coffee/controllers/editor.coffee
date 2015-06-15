module.exports = ['$scope', ($scope) ->
  $scope.default =
    from:
      image: 'ubuntu'
      tag: 'latest'
    maintainer:
      name: 'Anonymous'
      email: 'anonymous@example.com'
    body: []

  $scope.docker =
    from:
      image: ''
      tag: ''
    maintainer:
      name: ''
      email: ''
    body: []

  $scope.genDockerfile = ->
    image = $scope['docker']['from']['image'] || $scope['default']['from']['image']
    tag = $scope['docker']['from']['tag'] || $scope['default']['from']['tag']
    name = $scope['docker']['maintainer']['name'] || $scope['default']['maintainer']['name']
    email = $scope['docker']['maintainer']['email'] || $scope['default']['maintainer']['email']

    dockerfile = [
      "FROM #{image}:#{tag}"
      "MAINTAINER #{name} <#{email}>"
      ""
    ]

    dockerfile.join '\n'

  $scope.test = ->
    console.log 'test'
]

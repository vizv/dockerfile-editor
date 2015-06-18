Ps = require 'perfect-scrollbar'

class DockerInstruction
  @types = [
    '空行'
    '注释'
    'RUN'
    'CMD'
    'LABEL'
    'EXPOSE'
    'ENV'
    'ADD'
    'COPY'
    'ENTRYPOINT'
    'VOLUME'
    'USER'
    'WORKDIR'
    'ONBUILD'
  ]
  constructor: (@checked = false, @type = @constructor.types.indexOf('空行'), @data = {}) ->

module.exports = ['$scope', '$document', ($scope, $document) ->
  # set data model
  $scope.DockerInstruction = DockerInstruction

  # initialize perfect scrollbar
  scrollbars = $document[0].getElementsByClassName('scroller')
  $scope.$evalAsync =>
    Ps.initialize scrollbars[0]

  # initialize default scope variables
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

  $scope.instructions = []

  # actions
  $scope.newInstruction = ->
    instruction = new DockerInstruction
    $scope.instructions.push instruction

  # helpers
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
]

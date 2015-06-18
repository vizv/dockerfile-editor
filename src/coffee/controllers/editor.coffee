Ps = require 'perfect-scrollbar'
_ = require 'underscore'

module.exports = ['$scope', '$document', ($scope, $document) ->
  # constants
  $scope.instructionTypes = [
    [
      '空行'
      '注释'
      'RUN'
      'CMD'
    ]
    [
      'LABEL'
      'EXPOSE'
      'ENV'
      'ADD'
    ]
    [
      'COPY'
      'ENTRYPOINT'
      'VOLUME'
    ]
    [
      'USER'
      'WORKDIR'
      'ONBUILD'
    ]
  ]

  # set data model
  $scope.DockerInstruction = class
    @types = _.flatten $scope.instructionTypes
    constructor: (@checked = false, @type = @constructor.types.indexOf('空行'), @data = {}) ->
    toggleMenu: ->
      _.each $scope.instructions, (ins) =>
        ins.showDropdown = false if @ != ins
      @showDropdown = !@showDropdown
    setType: (type) ->
      @type = @constructor.types.indexOf(type)
    compile: ->
      switch @constructor.types[@type]
        when '空行' then ''
        when '注释' then "\# #{@data.comment || ''}"
        else "#{@constructor.types[@type]} \# Not implemented"

  $scope.instructions = []

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

  # actions
  $scope.newInstruction = ->
    instruction = new $scope.DockerInstruction
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

    dockerfile = dockerfile.concat _.map $scope.instructions, (ins) -> ins.compile()

    dockerfile.join '\n'
]

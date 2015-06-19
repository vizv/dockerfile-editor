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
    ]
  ]

  # set data model
  $scope.DockerInstruction = class
    @types = _.flatten $scope.instructionTypes
    @lastClick = null
    constructor: (@checked = false, @onBuild = false, type = '空行', @data = {}) ->
      @type = @constructor.types.indexOf(type)
    toggleMenu: ->
      _.each $scope.instructions, (ins) => ins.showDropdown = false if @ != ins
      @showDropdown = !@showDropdown
    onClick: ($event) ->
      # query checked instructions
      checkedIns = _.filter $scope.instructions, (ins) => ins.checked

      # unless ctrl key is pressed, uncheck others
      unless $event.ctrlKey
        _.each $scope.instructions, (ins) => ins.checked = false if @ != ins

      # if ctrl is pressed or without multiple selection, toggle checkbox
      if $event.ctrlKey or checkedIns.length <= 1
        @checked = !@checked
      else
        @checked = true

      if $event.shiftKey
        if @constructor.lastClick == @
          @checked = false
        else
          first = $scope.instructions.indexOf @constructor.lastClick
          last = $scope.instructions.indexOf @
          [first, last] = [last, first] if last < first
          _.each $scope.instructions[first..last], (ins) => ins.checked = true
      else
        @constructor.lastClick = @

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

Ps = require 'perfect-scrollbar'
_ = require 'underscore'

module.exports = ['$scope', '$document', ($scope, $document) ->
  # bridge underscore
  $scope._ = _

  # constants
  $scope.instructionSpecs = [
    [
      {
        name: '空行'
        # default: {}
        # hints: {}
        # example: {}
      }
      {
        name: '注释'
        default: {content: ''}
        hints: {content: '在这里输入注释'}
        example: {content: '注释例子'}
      }
      {
        name: 'RUN'
        default: {exec: false, shell: '', exec: []}
        example: {exec: false, shell: 'ping localhost', exec: ['ping', 'localhost']}
      }
      {
        name: 'CMD'
        default: {exec: false, shell: '', exec: []}
        example: {exec: false, shell: 'ping localhost', exec: ['ping', 'localhost']}
      }
    ]
    [
      {
        name: 'EXPOSE'
        default: {ports: []}
        example: {ports: [80, 443]}
      }
      {
        name: 'ENV'
        default: {multiple: false, single: {}, multiple: []}
        example: {multiple: false, single: {name: 'FOOBAR', value: 'foo bar'}, multiple: [{name: 'FOO', value: 'foo value'}, {name: 'BAR', value: 'bar value'}]}
      }
      {
        name: 'ADD'
        default: {match: false, src: [], dest: ''}
        example: {match: false, src: [{file: 'foo.txt', match: false}, {file: 'bar*.log', match: true}, {file: 'file with space.dat', match: false}], dest: '/app/'}
      }
    ]
    [
      {
        name: 'COPY'
        default: {match: false, src: [], dest: ''}
        example: {match: false, src: [{file: 'foo.txt', match: false}, {file: 'bar*.log', match: true}, {file: 'file with space.dat', match: false}], dest: '/app/'}
      }
      {
        name: 'ENTRYPOINT'
        default: {exec: false, shell: '', exec: []}
        example: {exec: false, shell: 'ping localhost', exec: ['ping', 'localhost']}
      }
      {
        name: 'VOLUME'
        default: {volumes: []}
        example: {volumes: ['/data', '/log']}
      }
    ]
    [
      {
        name: 'USER'
        default: {user: ''}
        example: {user: 'daemon'}
      }
      {
        name: 'WORKDIR'
        default: {path: ''}
        example: {path: '/app'}
      }
    ]
  ]

  # set data model
  $scope.instructionTypes = {}
  _.each _.flatten($scope.instructionSpecs), (type) ->
    $scope.instructionTypes[type.name] = type
  $scope.DockerInstruction = class
    @types = _.keys $scope.instructionTypes
    @lastClick = null

    constructor: (@checked = false, @onBuild = false, type = '空行', @data = {}) ->
      @type = @constructor.types.indexOf(type)

    toggleMenu: ->
      _.each $scope.instructions, (ins) => ins.showDropdown = false if @ != ins
      @showDropdown = !@showDropdown

    onClick: ($event) ->
      unless $event.shiftKey
        @constructor.lastClick = @

    onClickCheckbox: ($event) ->
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

    setType: (type) ->
      @type = @constructor.types.indexOf(type)
      _.defaults @data, $scope.instructionTypes[type].default

    getType: ->
      @constructor.types[@type]

    compile: ->
      switch @constructor.types[@type]
        when '空行' then ''
        when '注释' then "\# #{@data.content}"
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

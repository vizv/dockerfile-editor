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
        renderType: 'BLANK'
        default: {}
        hints: {}
        example: {}
      }
      {
        name: '注释'
        renderType: 'COMMENT'
        default: {content: ''}
        hints: {content: '注释'}
        example: {content: '注释例子'}
      }
      {
        name: 'RUN'
        renderType: 'EXEC'
        default: {toggle: false, shell: '', exec: ['']}
        hints: {shell: '执行的命令和参数', exec: {cmd: '执行的命令', param: '执行命令的参数'}}
        example: {toggle: false, shell: 'ping localhost', exec: ['ping', 'localhost']}
      }
      {
        name: 'CMD'
        renderType: 'EXEC'
        default: {toggle: false, shell: '', exec: []}
        hints: {shell: '默认执行的命令和参数', exec: {cmd: '默认执行的命令', param: '默认执行命令的参数'}}
        example: {toggle: false, shell: 'ping localhost', exec: ['ping', 'localhost']}
      }
    ]
    [
      {
        name: 'EXPOSE'
        renderType: 'PORT'
        default: {ports: []}
        hints: {port: '要映射的端口'}
        example: {ports: [80, 443]}
      }
      {
        name: 'ENV'
        renderType: 'MAP'
        default: {toggle: false, single: {}, multiple: []}
        hints: {single: {name: '环境变量名', value: '环境变量值'}}
        example: {toggle: false, single: {name: 'FOOBAR', value: 'foo bar'}, multiple: [{name: 'FOO', value: 'foo value'}, {name: 'BAR', value: 'bar value'}]}
      }
      {
        name: 'ADD'
        renderType: 'FILE'
        default: {toggle: false, src: [], dest: ''}
        example: {toggle: false, src: [{file: 'foo.txt', match: false}, {file: 'bar*.log', match: true}, {file: 'file with space.dat', match: false}], dest: '/app/'}
      }
    ]
    [
      {
        name: 'COPY'
        renderType: 'FILE'
        default: {toggle: false, src: [], dest: ''}
        example: {toggle: false, src: [{file: 'foo.txt', match: false}, {file: 'bar*.log', match: true}, {file: 'file with space.dat', match: false}], dest: '/app/'}
      }
      {
        name: 'ENTRYPOINT'
        renderType: 'EXEC'
        default: {toggle: false, shell: '', exec: []}
        hints: {shell: '入口命令和参数', exec: {cmd: '入口命令', param: '入口命令的参数'}}
        example: {toggle: false, shell: 'ping localhost', exec: ['ping', 'localhost']}
      }
      {
        name: 'VOLUME'
        renderType: 'VOL'
        default: {volumes: []}
        example: {volumes: ['/data', '/log']}
      }
    ]
    [
      {
        name: 'USER'
        renderType: 'USER'
        default: {user: ''}
        example: {user: 'daemon'}
      }
      {
        name: 'WORKDIR'
        renderType: 'PATH'
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
    @new = (checked = false, onBuild = false, type = '空行', data = {}) ->
      new $scope.DockerInstruction checked, onBuild, type, data

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

    getRenderType: ->
      $scope.instructionTypes[@getType()].renderType

    hasToggle: ->
      $scope.instructionTypes[@getType()].default.toggle != undefined

    toggleMode: ->
      @data.toggle = !@data.toggle

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
  $scope.ListUtil =
    add: (array, items) ->
      array.concat items

    insertUp: (array, target, item) ->
      if (i = array.indexOf target) != -1
        array.splice i, 0, item

    insertDown: (array, target, item) ->
      if (i = array.indexOf target) != -1
        array.splice i + 1, 0, item

    removeOne: (array, item) ->
      if (i = array.indexOf item) != -1
        array.splice i, 1

    removeAll: (array, tag = 'checked') ->
      for i in [array.length - 1..0]
        if array[i][tag]
          array.splice i, 1

    moveUp: (array, tag = 'checked') ->
      for i in [0..array.length - 1]
        if array[i][tag] and array[i - 1] and !array[i - 1][tag]
          [array[i], array[i - 1]] = [array[i - 1], array[i]]

    moveDown: (array, tag = 'checked') ->
      for i in [array.length - 1..0]
        if array[i][tag] and array[i + 1] and !array[i + 1][tag]
          [array[i], array[i + 1]] = [array[i + 1], array[i]]


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

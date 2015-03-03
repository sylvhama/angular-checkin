'use strict'

angular.module('checkinHSKApp').controller 'CheckCtrl', ['$rootScope','$scope', '$http', '$timeout', ($rootScope, $scope, $http, $timeout) ->
  $scope.people = []
  $scope.hideCame = false
  $scope.action = 'Hide'
  $scope.limitTo = 20
  $scope.search = ''
  $scope.filter = ''
  $scope.predicate = 'name'
  $scope.reverse = false

  timeoutId = 0
  min = 0
  limit = 3

  getPeople = () ->
    $http.post("./php/do.php?r=selectPeople"
      data: {
        hash: '3LoZNrrZ0nLHd5S95EIMhzsSRt7ufC0CJbDr0MLy'
      }
    ).success((data, status) ->
      if !data.error
        $scope.people = data
        for person in $scope.people
          person.came = parseInt(person.came)
        startTimer()
      else
        console.log "[Error][GetPeople] " + data.error
    ).error (data, status) ->
      console.log "[Error][GetPeople] " + status

  getUpdate = () ->
    $http.post("./php/do.php?r=selectPeople"
      data: {
        hash: '3LoZNrrZ0nLHd5S95EIMhzsSRt7ufC0CJbDr0MLy'
      }
    ).success((data, status) ->
      if !data.error
        for person in $scope.people
          for newPerson in data
            if person.id == newPerson.id
              if parseInt(person.came) != parseInt(newPerson.came)
                person.came = parseInt(newPerson.came)
              break
        startTimer()
      else
        console.log "[Error][UpdatePeople] " + data.error
    ).error (data, status) ->
      console.log "[Error][UpdatePeople] " + status

  updatePersonCame = (person) ->
    $http.post("./php/do.php?r=updatePersonCame"
      data: {
        id: person.id,
        came: person.came,
        hash: '3LoZNrrZ0nLHd5S95EIMhzsSRt7ufC0CJbDr0MLy'
      }
    ).success((data, status) ->
      if data.error
        alert "[Error] update impossible"
    ).error (data, status) ->
      alert "[Error] Server problem"

  $scope.updateCame = ($event, person) ->
    $event.preventDefault()
    if person.came == 1 and $rootScope.media!='mobile'
      person.came = 0
      updatePersonCame(person)
    else if person.came == 0
      person.came = 1
      updatePersonCame(person)

  $scope.swipeUpdateCame = ($event, person) ->
    $event.preventDefault()
    if person.came == 1 and $rootScope.media=='mobile'
      person.came = 0
      updatePersonCame(person)

  $scope.hasCame = (person) ->
    if $scope.hideCame
      if person.came == 1 then return true
      else if person.came == 0 then return false

  $scope.toggleAction = () ->
    $scope.hideCame = !$scope.hideCame
    if $scope.action == 'Hide' then $scope.action = 'Show'
    else if $scope.action == 'Show' then $scope.action = 'Hide'

  $scope.nextPage = () ->
    if $scope.limitTo < $scope.people.length
      $scope.limitTo = $scope.limitTo+10

  $scope.resetFilter = () ->
    $scope.search = ''
    $scope.filter = ''
    $scope.resetLimitTo(20)

  $scope.setFilter = (search) ->
    $scope.filter = search
    $scope.resetLimitTo(20)

  $scope.resetLimitTo = (value) ->
    $scope.limitTo = value

  $scope.setOrder = (predicate, reverse) ->
    if $scope.predicate == predicate
      $scope.reverse = !$scope.reverse
    else
      $scope.predicate = predicate
      $scope.reverse = reverse

  $scope.getTotalChecked = () ->
    total = 0
    for person in $scope.people
      if person.came == 1 then total++
    return total

  getPeople()

  myTimer = ->
    min++

  startTimer = () ->
    timeoutId =  $timeout( ->
      myTimer()
      if min == limit
        stopTimer()
      else
        startTimer()
    ,60000)

  stopTimer = ->
    $timeout.cancel(timeoutId)
    min = 0
    getUpdate()

  $scope.$on "$destroy", () ->
    $timeout.cancel(timeoutId);
]
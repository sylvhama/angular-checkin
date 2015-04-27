'use strict'

angular.module('checkinApp').controller 'CheckCtrl', ['$rootScope','$scope', '$http', '$timeout', '$window', '$localForage', ($rootScope, $scope, $http, $timeout, $window, $localForage) ->
  $scope.people = []
  $scope.peopleWaiting = []
  $scope.hideCame = false
  $scope.action = 'Hide'
  $scope.limitTo = 20
  $scope.search = ''
  $scope.filter = ''
  $scope.predicate = 'name'
  $scope.reverse = false
  $scope.online = navigator.onLine
  $scope.closeAlert = false

  timeoutId = 0
  min = 0
  limit = 5

  getPeople = (auto) ->
    $http.post("./php/do.php?r=selectPeople"
      data: {
        hash: '3LoZNrrZ0nLHd5S95EIMhzsSRt7ufC0CJbDr0MLy'
      }
    ).success((data, status) ->
      if !data.error
        $scope.people = data
        for person in $scope.people
          person.came = parseInt(person.came)
        $localForage.setItem('people', $scope.people)
        if auto
          $scope.$apply()
        startTimer()
      else
        console.log "[Error][GetPeople] " + data.error
    ).error (data, status) ->
      console.log "[Error][GetPeople] " + status

  getUpdate = () ->
    if $scope.online
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

  updatePersonCame = (person, wasWaiting) ->
    $localForage.setItem('people', $scope.people)
    if $scope.online and !wasWaiting
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

    if !$scope.online and !wasWaiting
      already = false
      for waiter, index in $scope.peopleWaiting
        if waiter.id == person.id
          $scope.peopleWaiting[index].came = person.came
          already = true
      if !already
        $scope.peopleWaiting.push(person)
      $localForage.setItem('peopleWaiting', $scope.peopleWaiting)

  updateWaiters = (waiters, auto) ->
    $http.post("./php/do.php?r=updateWaiters"
      data: {
        waiters: waiters,
        hash: '3LoZNrrZ0nLHd5S95EIMhzsSRt7ufC0CJbDr0MLy'
      }
    ).success((data, status) ->
      if data.error
        alert "[Error] update impossible"
      else
        $scope.people = data
        for person in $scope.people
          person.came = parseInt(person.came)
        $localForage.setItem('people', $scope.people)
        $localForage.setItem('peopleWaiting', [])
        $scope.peopleWaiting = []
        if auto
          $scope.$apply()
        startTimer()
    ).error (data, status) ->
      alert "[Error] Server problem"

  $scope.updateCame = ($event, person) ->
    $event.preventDefault()
    if person.came == 1 and $rootScope.media!='mobile'
      person.came = 0
      updatePersonCame(person, false)
    else if person.came == 0
      person.came = 1
      updatePersonCame(person, false)

  $scope.swipeUpdateCame = ($event, person) ->
    $event.preventDefault()
    if person.came == 1 and $rootScope.media=='mobile'
      person.came = 0
      updatePersonCame(person, false)

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

  $scope.doCloseAlert = () ->
    $scope.closeAlert = true

  $scope.displayAlert = () ->
    if $scope.closeAlert then return false
    else if !$scope.online then return true
    else return false

  if $scope.online
    $localForage.getItem('peopleWaiting').then( (data) ->
      if typeof data != 'undefined' and data.length > 0
        updateWaiters(data, false)
      else
        getPeople(false)
    )
  else
    $localForage.getItem('people').then( (data) ->
      if typeof data != 'undefined'
        $scope.people = data
    )
    $localForage.getItem('peopleWaiting').then( (data) ->
      if typeof data != 'undefined'
        $scope.peopleWaiting = data
    )

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

  $window.addEventListener 'offline', ((e) ->
    $scope.online = false
    $scope.closeAlert = false
    $scope.$apply()
  ), false

  $window.addEventListener 'online', ((e) ->
    $scope.online = true
    $scope.closeAlert = false
    if $scope.peopleWaiting.length > 0
      updateWaiters($scope.peopleWaiting, true)
    else
      getPeople(true)
  ), false
]
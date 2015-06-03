'use strict'

angular.module('checkinApp').controller 'RegisterCtrl', ['$scope', '$http', '$window', '$localForage', ($scope, $http, $window, $localForage) ->

  $scope.registered = false

  $scope.checkRegister = false
  $scope.otherError = false
  $scope.online = navigator.onLine
  $scope.closeAlert = false
  $scope.peopleWaitingR = []

  $scope.fields = {}
  $scope.fields.name = ''
  $scope.fields.company = ''
  $scope.fields.email = ''
  $scope.fields.phone = ''
  $scope.fields.department = ''
  $scope.fields.where = ''
  $scope.fields.otherWhere = ''

  addRegistration = () ->
    where = $scope.fields.where
    if $scope.fields.where == 'other'
      where = $scope.fields.otherWhere
    $http.post("./php/do.php?r=addRegistration"
      data: {
        name: $scope.fields.name,
        company: $scope.fields.company,
        email: $scope.fields.email,
        phone: $scope.fields.phone,
        department: $scope.fields.department,
        where: where,
        hash: '3LoZNrrZ0nLHd5S95EIMhzsSRt7ufC0CJbDr0MLy'
      }
    ).success((data, status) ->
      $scope.checkRegister = false
      $scope.registered = false
      if !data.error
        $scope.fields.name = ''
        $scope.fields.company = ''
        $scope.fields.email = ''
        $scope.fields.phone = ''
        $scope.fields.department = ''
        $scope.fields.where = ''
        $scope.fields.otherWhere = ''
      else
        console.log "[Error][AddRegistration] " + data.error
        alert('Error, please try again.')
    ).error (data, status) ->
      console.log "[Error][AddRegistration] " + status
      alert('Error, please try again.')

  addPeopleWaitingR = (peopleWaitingR) ->
    $http.post("./php/do.php?r=addPeopleWaitingR"
      data: {
        peopleWaitingR:peopleWaitingR,
        hash: '3LoZNrrZ0nLHd5S95EIMhzsSRt7ufC0CJbDr0MLy'
      }
    ).success((data, status) ->
      if !data.error
        $localForage.setItem('peopleWaitingR', [])
        $scope.peopleWaitingR = []
      else
        console.log "[Error][AddPeopleWaitingR] " + data.error
        alert('Error, data not saved.')
    ).error (data, status) ->
      console.log "[Error][AddPeopleWaitingR] " + status
      alert('Error, data not saved.')

  $scope.register = ($event) ->
    $event.preventDefault()
    $scope.checkRegister = true
    if !$scope.registered and $scope.myForm.$valid
      if $scope.fields.where != 'other' or ($scope.fields.where == 'other' and $scope.fields.otherWhere != '')
        if $scope.online
          $scope.registered = true
          $scope.otherError = false
          addRegistration()
        else
          waiterR = {}
          waiterR.name = $scope.fields.name
          waiterR.company = $scope.fields.company
          waiterR.email = $scope.fields.email
          waiterR.phone = $scope.fields.phone
          waiterR.department = $scope.fields.department
          waiterR.where = $scope.fields.where
          waiterR.otherWhere = $scope.fields.otherWhere
          waiterR.finalwhere = $scope.fields.where
          if $scope.fields.where == 'other'
            waiterR.finalwhere = $scope.fields.otherWhere
          $scope.peopleWaitingR.push(waiterR)
          $localForage.setItem('peopleWaitingR', $scope.peopleWaitingR)
          $scope.fields.name = ''
          $scope.fields.company = ''
          $scope.fields.email = ''
          $scope.fields.phone = ''
          $scope.fields.department = ''
          $scope.fields.where = ''
          $scope.fields.otherWhere = ''
          $scope.checkRegister = false
      else
        $scope.otherError = true


  $scope.doCloseAlert = () ->
    $scope.closeAlert = true

  $scope.displayAlert = () ->
    if $scope.closeAlert then return false
    else if !$scope.online then return true
    else return false

  if $scope.online
    $localForage.getItem('peopleWaitingR').then( (data) ->
      if typeof data != 'undefined' and data.length > 0
        addPeopleWaitingR(data)
    )
  else
    $localForage.getItem('peopleWaitingR').then( (data) ->
      if typeof data != 'undefined'
        $scope.peopleWaitingR = data
    )

  nowOffline = ->
    $scope.online = false
    $scope.closeAlert = false
    $scope.$apply()

  nowOnline = ->
    $scope.online = true
    $scope.closeAlert = false
    if $scope.peopleWaitingR.length > 0
      addPeopleWaitingR($scope.peopleWaiting)
    $scope.$apply()

  $window.addEventListener 'offline', nowOffline, false
  $window.addEventListener 'online', nowOnline, false

  $scope.$on "$destroy", (event) ->
    $window.removeEventListener('online', nowOnline, false)
    $window.removeEventListener('offline', nowOffline, false)

]

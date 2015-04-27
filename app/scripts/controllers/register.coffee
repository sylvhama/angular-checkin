'use strict'

angular.module('checkinApp').controller 'RegisterCtrl', ['$scope', '$http', '$window', ($scope, $http, $window) ->

  $scope.registered = false

  $scope.checkRegister = false
  $scope.otherError = false
  $scope.online = navigator.onLine
  $scope.closeAlert = false

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

  $scope.register = ($event) ->
    $event.preventDefault()
    $scope.checkRegister = true
    if !$scope.registered and $scope.myForm.$valid and $scope.online
      if $scope.fields.where != 'other' or ($scope.fields.where == 'other' and $scope.fields.otherWhere != '')
        $scope.registered = true
        $scope.otherError = false
        addRegistration()
      else
        $scope.otherError = true

  $scope.doCloseAlert = () ->
    $scope.closeAlert = true

  $scope.displayAlert = () ->
    if $scope.closeAlert then return false
    else if !$scope.online then return true
    else return false

  $window.addEventListener 'offline', ((e) ->
    $scope.online = false
    $scope.closeAlert = false
    $scope.$apply()
  ), false

  $window.addEventListener 'online', ((e) ->
    $scope.online = true
    $scope.closeAlert = false
    $scope.$apply()
  ), false

]

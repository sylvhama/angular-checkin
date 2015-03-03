'use strict'

angular.module('checkinHSKApp').directive 'placeholder', () ->
  restrict: 'C'

  link: (scope, element, attrs) ->

    $('input, textarea').placeholder()
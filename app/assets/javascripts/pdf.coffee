# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  if location.hash
    $('a[href=\'' + location.hash + '\']').tab 'show'

  activeTab = localStorage.getItem('activeTab')
  if activeTab
    $('a[href="' + activeTab + '"]').tab 'show'

  $('body').on 'click', 'a[data-toggle=\'tab\']', (e) ->
    e.preventDefault()
    tab_name = @getAttribute('href')
    if history.pushState
      history.pushState null, null, tab_name
    else
      location.hash = tab_name
    localStorage.setItem 'activeTab', tab_name
    $(this).tab 'show'
    false

  $(window).on 'popstate', ->
    anchor = location.hash or $('a[data-toggle=\'tab\']').first().attr('href')
    $('a[href=\'' + anchor + '\']').tab 'show'
    return
    
  return
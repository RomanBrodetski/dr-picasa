# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).on('click', '.photo-thumbnail', (event) ->
  photo_id = $(event.target).closest('a').data('id')
  album_id = $(event.target).closest('ul').data('id')
  $('#modal').load('/' + photo_id + '/comments?album_id=' + album_id, () ->
    $('#modal').modal())
  )

$(document).on('submit', 'form#comment', (event) ->
  $('form#comment button').addClass('disabled')
  $('form#comment button').attr('disabled', true)
  )